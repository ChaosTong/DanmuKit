//
//  LZDMManager.swift
//  DanmuKit
//
//  Created by ChaosTong on 2018/4/6.
//  Copyright © 2018年 ChaosTong. All rights reserved.
//

import Foundation

private let shared = LZDMManager()

public class LZDMManager: NSObject, WebSocketDelegate {
    
    public class var manager: LZDMManager {
        return shared
    }
    
    var lz_socket: WebSocket?
    
    /**
     链接服务器
     */
    public func connectWebSocketWithRoomId(roomId: String) {
        if let so = lz_socket {
            if so.isConnected {
                return
            }
        }
        lz_socket = WebSocket(url: URL(string: "ws://mbgows.plu.cn:8805/?room_id=\(roomId)&batch=1&group=0&connType=0")!)
        lz_socket?.disableSSLCertValidation = true
        lz_socket?.connect()
        lz_socket?.delegate = self
    }
    
    /**
     断开链接
     */
    public func cutoff() {
        if let _ = lz_socket {
            lz_socket?.disconnect()
            print("---断开龙珠弹幕---")
        }
    }
    
    public func websocketDidConnect(socket: WebSocketClient) {
        print("---成功连接龙珠弹幕---")
    }
    public func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        print("websocket is disconnected: \(String(describing: error?.localizedDescription))")
    }
    public func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        print("got some data: \(data.count)")
    }
    
    public func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        transModelWithContents(data: text) { (array, modelType) in
            if modelType == .Bullet {
                NotificationCenter.default.post(name: NSNotification.Name.init("LZNotificationBullet"), object: nil, userInfo: ["Bullet" : array])
            } else if modelType == .Gift {
                NotificationCenter.default.post(name: NSNotification.Name.init("LZNotificationGift"), object: nil, userInfo: ["Gift" : array])
            }
        }
    }
    
    func transModelWithContents(data: String, complete: @escaping transCompleteBlock) {
        
        let data: Data = data.data(using: .utf8)!
        let json = JSON.init(data: data)
        
        var bulletArray = [LZBulletModel]()
        var giftArray = [LZGiftModel]()
        
        if let arr = json.array {
            for v in arr {
                let type = v["type"].stringValue
                if type == "chat" {
                    let m = LZBulletModel.init(v: v)
                    bulletArray.append(m)
                }
                if type == "gift" {
                    let m = LZGiftModel.init(v: v)
                    giftArray.append(m)
                }
            }
        }
        
        if bulletArray.count > 0 {
            complete(bulletArray, .Bullet)
        }
        if giftArray.count > 0 {
            complete(giftArray, .Gift)
        }
    }
    
}

