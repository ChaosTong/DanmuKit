//
//  PDDMManager.swift
//  DanmuKit
//
//  Created by ChaosTong on 2018/4/7.
//  Copyright © 2018年 ChaosTong. All rights reserved.
//

import Foundation

public struct postPackPD {
    var length: AnyObject?
    var lengthTwice: AnyObject?
    var postCode: AnyObject?
}

public class pandaInfo {
    var appid: String = ""
    public var rid: Int = 0
    var sign: String = ""
    var authType: String = ""
    var ts: Int = 0
    var chat_addr: String = ""
    
    public init(v: JSON) {
        self.appid = v["data"]["appid"].stringValue
        self.rid = v["data"]["rid"].intValue
        self.sign = v["data"]["sign"].stringValue
        self.authType = v["data"]["authType"].stringValue
        self.ts = v["data"]["ts"].intValue
        self.chat_addr = v["data"]["chat_addr_list"][0].stringValue
    }
}

public class PDDManager: NSObject, GCDAsyncSocketDelegate {
    
    var socket = GCDAsyncSocket()
    var pack = postPackPD()
    var info: pandaInfo!
    var connectTimer: Timer?
    var combieData = Data()
    
    public class var shared: PDDManager {
        struct Static {
            static let instance: PDDManager = PDDManager()
        }
        return Static.instance
    }
    
    /**
     链接服务器
     */
    public func connectSocketWithPandaInfo(info: pandaInfo) {
        self.socket = GCDAsyncSocket.init(delegate: self, delegateQueue: DispatchQueue.main)
        self.info = info
        do {
            var myArray2 : [String] = info.chat_addr.components(separatedBy: ":")
            try self.socket.connect(toHost:myArray2[0], onPort: UInt16(myArray2[1])!, withTimeout: 30)
        }
        catch {
            print("connect error is:\(error)")
        }
    }
    
    //MARK: - 连接成功
    public func socket(_ sock: GCDAsyncSocket, didConnectToHost host: String, port: UInt16) {
        NSLog("---认证服务器连接成功---")
        
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
    
    //MARK: - 接受数据
    public func socket(_ sock: GCDAsyncSocket, didRead data: Data, withTag tag: Int) {
        if (data.count != 0) {
            let enCode: Int16 = 125
            let endCode_1: Int16 = data.scanValue(start: data.count - 1, length: 1)
            let endCode_2: Int16 = data.scanValue(start: data.count - 2, length: 1)
            
            if (endCode_1 == enCode && endCode_2 == enCode) {
                let a: Int16 = data.scanValue(start: 1, length: 1)
                let b: Int16 = data.scanValue(start: 3, length: 1)
                
                if (a == 6 && b == 3) { // danmu data
                    
                    self.combieData = Data()
                    self.combieData.append(data)
                    
                    PDTransModelTool().transModelWithContents(data: self.combieData, complete: { (array, modelType) in
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
                    startKLTimer()
                    print(postDate)
                }
                self.combieData.append(data)
                print("conbiane==============")
            }
            
        }
        self.socket.readData(withTimeout: -1, buffer: nil, bufferOffset: 0, maxLength: 1024, tag: 1)
    }
    
    //MARK: - 断开连接
    public func socketDidDisconnect(_ sock: GCDAsyncSocket, withError err: Error?) {
        NSLog("---弹幕服务器断开---")
    }
    
    //MARK: - 心跳包
    @objc func longConnectToSocket() {
        let keepLive = Data(bytes: [0x00, 0x06, 0x00, 0x00])
        self.socket.write(keepLive, withTimeout: 300, tag: 1)
    }
    
    public func socket(_ sock: GCDAsyncSocket, didWriteDataWithTag tag: Int) {
        //发送完数据手动读取，-1不设置超时
        sock.readData(withTimeout: BAReadTimeOut, tag: tag)
    }
    
    func startKLTimer() {
        self.connectTimer = Timer.scheduledTimer(timeInterval: 300, target: self, selector: #selector(longConnectToSocket), userInfo: nil, repeats: true)
        self.connectTimer?.fire()
        print("---发送心跳包---")
    }
    
    func cutOffSocket() {
        self.connectTimer?.invalidate()
        self.socket.disconnect()
    }
}
