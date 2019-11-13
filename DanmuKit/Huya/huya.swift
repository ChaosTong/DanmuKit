//
//  huya.swift
//  DanmuKit
//
//  Created by chaostong on 2019/11/13.
//  Copyright © 2019 ChaosTong. All rights reserved.
//

import Foundation
import JavaScriptCore

public class Huya: NSObject, WebSocketDelegate {
    public class var shared: Huya {
        struct Static {
            static let instance: Huya = Huya()
        }
        return Static.instance
    }
    
    let huyaJSContext = JSContext()
    let huyaServer = URL(string: "wss://cdnws.api.huya.com")
    var huyaUserInfo = ("", "", "")
    var lz_socket: WebSocket?
    var heartbeatTimer: DispatchSourceTimer?
    private let timerQueue = DispatchQueue(label: "com.xjbeta.iina+.WebSocketKeepLive")

    
    public func connect(_ room: String) {
        if let huyaFilePath = Bundle.main.path(forResource: "huya", ofType: "js") {
            huyaJSContext?.evaluateScript(try? String(contentsOfFile: huyaFilePath))
        }
        Enough.requestForHTML(method: .get, url: "https://m.huya.com/qingwa666", params: nil, isData: nil, headers: ["User-Agent": "Mozilla/5.0 (iPhone; CPU iPhone OS 11_0 like Mac OS X) AppleWebKit/604.1.38 (KHTML, like Gecko) Version/11.0 Mobile/15A372 Safari/604.1"], isRecur: false) { (data, error) in
            guard let data = data else { return }
            guard let html = String.init(data: data, encoding: .utf8) else { return }
            
            let lSid = html.subString(from: "var SUBSID = '", to: "';")
            let lTid = html.subString(from: "var TOPSID = '", to: "';")
            let lUid = html.subString(from: "ayyuid: '", to: "',")
            self.huyaUserInfo = (lSid, lTid, lUid)
            
            if let so = self.lz_socket {
                if so.isConnected {
                    return
                }
            }
            self.lz_socket = WebSocket(url: self.huyaServer!)
//            self.lz_socket?.disableSSLCertValidation = false
            self.lz_socket?.connect()
            self.lz_socket?.delegate = self
        }
    }
    
    func startHeartbeat() {
        heartbeatTimer?.cancel()
        heartbeatTimer = nil
        heartbeatTimer = DispatchSource.makeTimerSource(flags: [], queue: timerQueue)
        if let heartbeatTimer = heartbeatTimer {
            heartbeatTimer.schedule(deadline: .now(), repeating: .seconds(120))
            heartbeatTimer.setEventHandler {
                self.lz_socket?.write(ping: Data(), completion: nil)
                print("---发送心跳包---")
            }
            heartbeatTimer.resume()
        }
    }
    
    /**
     断开链接
     */
    public func cutoff() {
        if let _ = lz_socket {
            lz_socket?.disconnect()
            heartbeatTimer?.cancel()
            heartbeatTimer = nil
            print("---断开龙珠弹幕---")
        }
    }
    
    public func websocketDidConnect(socket: WebSocketClient) {
        print("---成功连接龙珠弹幕---")
        huyaJSContext?.evaluateScript("""
                        var wsUserInfo = new HUYA.WSUserInfo;
                        wsUserInfo.lSid = "\(huyaUserInfo.0)";
                        wsUserInfo.lTid = "\(huyaUserInfo.1)";
                        wsUserInfo.lUid = "\(huyaUserInfo.2)";
                        wsUserInfo.sGuid = "111111111";
                        """)
        let result = huyaJSContext?.evaluateScript("""
            new Uint8Array(sendRegister(wsUserInfo));
        """)
                    
        let data = Data(result?.toArray() as? [UInt8] ?? [])
//        try? webSocket.send(data: data)
        lz_socket?.write(data: data)
        startHeartbeat()
    }
    public func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        print("websocket is disconnected: \(String(describing: error?.localizedDescription))")
    }
    public func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
//        print("got some data: \(data.count)")
        let bytes = [UInt8](data)
        if let re = huyaJSContext?.evaluateScript("test(\(bytes));"),
            re.isString {
            let str = re.toString() ?? ""
            guard str != "HUYA.EWebSocketCommandType.EWSCmd_RegisterRsp" else {
                print("huya websocket inited EWSCmd_RegisterRsp")
                return
            }
            guard str != "HUYA.EWebSocketCommandType.Default" else {
                print("huya websocket WebSocketCommandType.Default \(data)")
                return
            }
            guard !str.contains("分享了直播间，房间号"), !str.contains("录制并分享了小视频"), !str.contains("进入直播间"), !str.contains("刚刚在打赏君活动中") else { return }
//            sendDM(str)
            print(str)
        }
    }
    
    public func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        transModelWithContents(data: text) { (array, modelType) in
            if modelType == .Bullet {
                NotificationCenter.default.post(name: NSNotification.Name.init("LZNotificationBullet"), object: nil, userInfo: ["Bullet" : array])
            }
        }
    }
    
    func transModelWithContents(data: String, complete: @escaping transCompleteBlock) {
        
//        let data: Data = data.data(using: .utf8)!
//        let json = JSON.init(data: data)
//
//        var bulletArray = [LZBulletModel]()
//        var giftArray = [LZGiftModel]()
//
//        if let arr = json.array {
//            for v in arr {
//                let type = v["type"].stringValue
//                if type == "chat" {
//                    let m = LZBulletModel.init(v: v)
//                    bulletArray.append(m)
//                }
//                if type == "gift" {
//                    let m = LZGiftModel.init(v: v)
//                    giftArray.append(m)
//                }
//            }
//        }
//
//        if bulletArray.count > 0 {
//            complete(bulletArray, .Bullet)
//        }
//        if giftArray.count > 0 {
//            complete(giftArray, .Gift)
//        }
    }
}
