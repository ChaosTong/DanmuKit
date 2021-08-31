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
        
        BASocketTool.shared.connectSocketWithRoomId(roomId: "156277")
        BASocketTool.shared.delegate = self
//        Huya.shared.connect("a16789")
//        Huya.shared.delegate = self
    }

}

extension ViewController: DanmuRecieveDelegate {
    func recieveMessages(userInfo: [AnyHashable : Any]?) {
        if let str = userInfo?["Bullet_HuYa"] as? BABulletModel {
            print("\(str.nn): \(str.txt)")
        }
        if let array = userInfo?["Bullet_DouYu"] as? [BABulletModel] {
            array.forEach({ (m) in
                print(m.description)
            })
        }
        if let gift = userInfo?["Gift_Douyu"] as? [BAGiftModel] {
            gift.forEach({ (m) in
                print(m.description)
            })
        }
    }
}
