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
        
//        BASocketTool.shared.connectSocketWithRoomId(roomId: "288016")
        Huya.shared.connect("")
        
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

}

