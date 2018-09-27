//
//  BASocketTool.swift
//  BulletAnalyzer
//
//  Created by ChaosTong on 2017/11/16.
//  Copyright © 2017年 ChaosTong. All rights reserved.
//

import Foundation

struct postPack {
    let length: UInt32 // 数据长度
    let lengthTwice: UInt32 // 第二次数据长度
    let postCode: UInt32 // 数据
}
typealias PostPack = postPack

let BAReadTimeOut: TimeInterval = -1
let BAPostCode = 0x2b1;
let BAEndCode = 0;
let BAServicePort1: UInt16 = 8601; //8601
let BAServicePort2: UInt16 = 8602; //8602
let BAServiceAddress = "openbarrage.douyutv.com"


public class BASocketTool: NSObject {
    
    var ignoreFreeGift = false
    var socket = GCDAsyncSocket()
//    let defaultSocket: BASocketTool? = nil
    
    var heartbeatTimer: DispatchSourceTimer! = DispatchSource.makeTimerSource(flags:DispatchSource.TimerFlags.init(rawValue: 0) , queue: nil)
    var roomId = ""
    var serviceConnected = false
    var roomConnected = false
    var contentData = Data()
    var line = 0
    var isReachable = false
    var memoryWarningCount = 0
    
    public class var shared: BASocketTool {
        struct Static {
            static let instance: BASocketTool = BASocketTool()
        }
        return Static.instance
    }
    /**
     链接服务器
     */
    public func connectSocketWithRoomId(roomId: String) {
        socket = GCDAsyncSocket.init(delegate: self, delegateQueue: DispatchQueue.main)
        self.roomId = roomId
        if socket.isConnected {
            cutoff()
        }
        // 1. 与服务器的socket链接起来
        do {
            try socket.connect(toHost: BAServiceAddress, onPort: BAServicePort2)
            
            serviceConnected = true
            memoryWarningCount = 0
//            ignoreFreeGift = false
            
            connectRoom()
        } catch {
            print("connect error is:\(error)")
        }
    }
    /**
     链接房间弹幕服务器
     */
    func connectRoom() {
        print("链接服务器")
        let pack = ("type@=loginreq/roomid@=\(roomId)/").packToData
        socket.write(pack, withTimeout: BAReadTimeOut, tag: 1)
    }
    /**
     入组
     */
    func joinGroup() {
        print("发送入组消息")
        let pack = ("type@=joingroup/rid@=\(roomId)/gid@=-9999/").packToData
        socket.write(pack, withTimeout: BAReadTimeOut, tag: 1)
    }
    /**
     开始发送心跳消息
     */
    func startHeartbeat() {
        heartbeatTimer.schedule(deadline: DispatchTime.now(), repeating: 30.0)
        heartbeatTimer.setEventHandler {
            self.heartBeat()
        }
        heartbeatTimer.resume()
    }
    @objc func heartBeat() {
        let pack = ("type@=keeplive/tick@=%\(String().timeString)/").packToData
        socket.write(pack, withTimeout: BAReadTimeOut, tag: 1)
    }
    /**
     断开链接
     */
    public func cutoff() {
        print("断开链接")
        line = 0
        let pack = "type@=logout/".packToData
        socket.write(pack, withTimeout: BAReadTimeOut, tag: 1)
        if heartbeatTimer != nil { heartbeatTimer.suspend() }
        socket.disconnect()
    }
    /**
     更换线路
     */
    func changeLine(line: Int) {
        DispatchQueue.global(qos: .userInitiated).async {
            if line == self.line { return }
            self.line = line
            
            let servicePort = self.line == 1 ? BAServicePort1 : BAServicePort2
            // 1. 与服务器的socket链接起来
            do {
                try self.socket.connect(toHost: BAServiceAddress, onPort: servicePort)
                print("客户端连接服务器成功")
                self.serviceConnected = true
                self.connectRoom()
            } catch {
                print("客户端连接服务器失败")
                self.serviceConnected = false
            }
        }
    }
    /**
     处理网络状态变化
     */
    /**
     处理服务器返回数据
     */
    func handleServiceReply(replayModel: BAReplyModel) {
        if replayModel.type == BAInfoType.LoginReply {
            joinGroup()
            startHeartbeat()
        }
    }
    func receiveMemoryWarning() {
        memoryWarningCount += 1
        if memoryWarningCount == 1 {
            cutoff()
            print("弹幕服务器炸了")
        }
    }
}

extension BASocketTool: GCDAsyncSocketDelegate {
    /**
     断开连接
     
     @param sock socket
     @param err 错误信息
     */
    public func socketDidDisconnect(_ sock: GCDAsyncSocket, withError err: Error?) {
        print("连接失败: \(String(describing: err))")
        if err.debugDescription.contains("Code=7") { //服务器认为心跳包问题断开, 重连
            connectSocketWithRoomId(roomId: roomId)
        } else {
            print("正常断开")
        }
    }
    /**
     读取数据
     @discussion 客户端已经获取到内容
     @param sock socket
     @param data 数据
     @param tag tag
     */
    public func socket(_ sock: GCDAsyncSocket, didRead data: Data, withTag tag: Int) {
        if data.count != 0 {
            var endCode: UInt8 = 0
            data.copyBytes(to: &endCode , from: data.count - 1 ..< data.count)
            if (endCode == 0) {
                contentData.append(data)
                BATransModelTool().transModelWithData(data: contentData, ignoreFreeGift: ignoreFreeGift, complete: { (array, modelType) in
                    if modelType == .Bullet {
                        NotificationCenter.default.post(name: NSNotification.Name.init("BANotificationBullet"), object: nil, userInfo: ["Bullet" : array])
                    } else if modelType == .Gift {
                        NotificationCenter.default.post(name: NSNotification.Name.init("BANotificationGift"), object: nil, userInfo: ["Gift" : array])
                    } else if modelType == .Reply {
                        if let f = array.first as? BAReplyModel {
                            self.handleServiceReply(replayModel: f)
                        }
                    }
                })
                contentData = Data()
            } else {
                contentData.append(data)
            }
        }
        self.socket.readData(withTimeout: BAReadTimeOut, tag: 0)
    }
    /**
     数据发送成功
     
     @param sock socket
     @param tag tag
     */
    public func socket(_ sock: GCDAsyncSocket, didWriteDataWithTag tag: Int) {
        //发送完数据手动读取，-1不设置超时
        sock.readData(withTimeout: BAReadTimeOut, tag: tag)
    }
    /**
     连接成功
     @discussion 客户端链接服务器端成功, 客户端获取地址和端口号
     @param sock socket
     @param host IP
     @param port 端口号
     */
    public func socket(_ sock: GCDAsyncSocket, didConnectToHost host: String, port: UInt16) {
        let socket = BASocketTool.shared
        socket.socket = self.socket
    }
    
}
