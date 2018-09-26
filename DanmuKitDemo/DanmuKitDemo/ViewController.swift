//
//  ViewController.swift
//  DanmuKitDemo
//
//  Created by ChaosTong on 2018/4/5.
//  Copyright © 2018年 ChaosTong. All rights reserved.
//

import UIKit
import DanmuKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(bullet(_:)), name: NSNotification.Name.init("BANotificationBullet"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(gift(_:)), name: NSNotification.Name.init("BANotificationGift"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(lzBullet(_:)), name: NSNotification.Name.init("LZNotificationBullet"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(lzGift(_:)), name: NSNotification.Name.init("LZNotificationGift"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(pdBullet(_:)), name: NSNotification.Name.init("PDNotificationBullet"), object: nil)
        
//        BASocketTool.shared.connectSocketWithRoomId(roomId: "74960")

//        LZDMManager.manager.connectWebSocketWithRoomId(roomId: "2241164")
//        LZAnalyzerCenter.shared.beginObserving()
        
//        let dict = "{\"errno\":0,\"errmsg\":\"\",\"data\":{\"appid\":\"134287728\",\"rid\":-49325502,\"sign\":\"016464201d55793f17faff41a2be0453\",\"authType\":\"4\",\"ts\":1537929846000,\"chat_addr_list\":[\"118.89.11.38:443\",\"118.89.11.13:443\"]}}"
//        if let jsonStr = dict.data(using: String.Encoding.utf8, allowLossyConversion: false) {
//            let json = JSON(data: jsonStr)
//            PDDManager.shared.connectSocketWithPandaInfo(info: pandaInfo.init(v: json))
//        }
        
//        QieManager.shared.startTolink("497383565_1537932699")
        QieManager.shared.linkQie("77777")
    }

    @objc func gift(_ noti: Notification) {
        if let dict = noti.userInfo {
            if let _ = dict["Gift"] as? [BAGiftModel] {
                
            }
        }
    }
    
    @objc func bullet(_ noti: Notification) {
        if let dict = noti.userInfo {
            if let array = dict["Bullet"] as? [BABulletModel] {
                array.forEach({ (m) in
                    print(m.description)
                })
            }
        }
    }
    
    @objc func lzGift(_ noti: Notification) {
        if let dict = noti.userInfo {
            if let array = dict["Gift"] as? [LZGiftModel] {
                array.forEach({ (m) in
                    print("礼物🎁",m.description)
                })
            }
        }
    }
    
    @objc func lzBullet(_ noti: Notification) {
        if let dict = noti.userInfo {
            if let array = dict["Bullet"] as? [LZBulletModel] {
                array.forEach({ (m) in
                    print("弹幕🥚",m.description)
                })
            }
        }
    }

    @objc func pdBullet(_ noti: Notification) {
        if let dict = noti.userInfo {
            if let array = dict["Bullet"] as? [PDBulletModel] {
                array.forEach({ (m) in
                    print("弹幕🥚",m.description)
                })
            }
        }
    }

}

