//
//  PDSocketTool.swift
//  DanmuKit
//
//  Created by ChaosTong on 2018/4/7.
//  Copyright © 2018年 ChaosTong. All rights reserved.
//

import Foundation

public class PDSocketTool: NSObject {

    var socket = GCDAsyncSocket()
    
    var heartbeatTimer = Timer()
    var serviceConnected = false
    var roomConnected = false
    var contentData = Data()
    var memoryWarningCount = 0
    
    var info: pandaInfo!
    
    public class var shared: PDSocketTool {
        struct Static {
            static let instance: PDSocketTool = PDSocketTool()
        }
        return Static.instance
    }
    /**
     链接服务器
     */
    public func connectSocketWithRoomId(info: pandaInfo) {
        socket = GCDAsyncSocket.init(delegate: self, delegateQueue: DispatchQueue.main)
        self.info = info
        if socket.isConnected {
            cutoff()
        }
        // 1. 与服务器的socket链接起来
        do {
            var myArray2 : [String] = info.chat_addr.components(separatedBy: ":")
            try socket.connect(toHost: myArray2[0], onPort: UInt16(myArray2[1])!)
            
            serviceConnected = true
            memoryWarningCount = 0
//            connectRoom()
        } catch {
            print("connect error is:\(error)")
        }
    }
    /**
     链接房间弹幕服务器
     */
    func connectRoom() {
        let k = "1"
        let t = "300"
        let postLogin = "u:" + "\(info.rid)" + "@" + "\(info.appid)" + "\n" +
            "k:" + k + "\n" +
            "t:" + "\(t)" + "\n" +
            "ts:" + "\(info.ts)" + "\n" +
            "sign:" + info.sign + "\n" +
            "authtype:" + info.authType
        //Cannot convert value of type '(String!) -> Data!' to expected argument type 'Data'
        let postLoginData = NSString().pack(toData: postLogin)//postLogin.packToData //NSString().pack(toData: postLogin)
        self.socket.write(postLoginData!, withTimeout: 30, tag: 1)
    }
    /**
     开始发送心跳消息
     */
    func startHeartbeat() {
        heartbeatTimer.invalidate()
        heartbeatTimer = Timer.scheduledTimer(timeInterval: 300, target: self, selector: #selector(heartBeat), userInfo: nil, repeats: true)
        RunLoop.current.add(heartbeatTimer, forMode: .commonModes)
        heartbeatTimer.fire()
        print("---发送心跳包---")
    }
    @objc func heartBeat() {
        let keepLive = Data(bytes: [0x00, 0x06, 0x00, 0x00])
        self.socket.write(keepLive, withTimeout: 300, tag: 1)
    }
    /**
     断开链接
     */
    func cutoff() {
        print("断开链接")
        heartbeatTimer.invalidate()
        socket.disconnect()
    }
    func receiveMemoryWarning() {
        memoryWarningCount += 1
        if memoryWarningCount == 1 {
            cutoff()
            print("弹幕服务器炸了")
        }
    }
}

extension PDSocketTool: GCDAsyncSocketDelegate {
    /**
     断开连接
     
     @param sock socket
     @param err 错误信息
     */
    public func socketDidDisconnect(_ sock: GCDAsyncSocket, withError err: Error?) {
        print("连接失败: \(String(describing: err))")
    }
    /**
     读取数据
     @discussion 客户端已经获取到内容
     @param sock socket
     @param data 数据
     @param tag tag
     */
    public func socket(_ sock: GCDAsyncSocket, didRead data: Data, withTag tag: Int) {
        if (data.count != 0) {
            let enCode: Int16 = 125
            let endCode_1: Int16 = data.scanValue(start: data.count - 1, length: 1)
            let endCode_2: Int16 = data.scanValue(start: data.count - 2, length: 1)
            
            if (endCode_1 == enCode && endCode_2 == enCode) {
                let a: Int16 = data.scanValue(start: 1, length: 1)
                let b: Int16 = data.scanValue(start: 3, length: 1)
                
                if (a == 6 && b == 3) { // danmu data
                    
                    self.contentData = Data()
                    self.contentData.append(data)
                    
                    PDTransModelTool().transModelWithContents(data: self.contentData, complete: { (array, modelType) in
                        if modelType == .Bullet {
                            NotificationCenter.default.post(name: NSNotification.Name.init("PDNotificationBullet"), object: nil, userInfo: ["Bullet" : array])
                        }
                    })
                    
                } else if (a == 6 && b == 1) { // keepalive data
                    
                } else { // error data
                    
                }
            } else {
                let a: Int16 = data.scanValue(start: 1, length: 1)
                let b: Int16 = data.scanValue(start: 3, length: 1)
                
                if (a == 6 && b == 6) { // login data
                    let postDate = data.subdata(in: 0..<8)
                    startHeartbeat()
                    print(postDate)
                }
                self.contentData.append(data)
                print("conbiane==============")
            }
            
        }
        self.socket.readData(withTimeout: -1, buffer: nil, bufferOffset: 0, maxLength: 1024, tag: 1)
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
        NSLog("---认证服务器连接成功---")
        let socket = PDSocketTool.shared
        socket.socket = self.socket
        connectRoom()
    }
    
}
