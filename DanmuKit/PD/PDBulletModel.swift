//
//  PDBulletModel.swift
//  DanmuKit
//
//  Created by ChaosTong on 2018/4/7.
//  Copyright © 2018年 ChaosTong. All rights reserved.
//

import Foundation

public struct PDBulletModel {
    
    public var description: String {
        return "\(nn):\(content)"
    }
    
    public var type = ""
    public var content = ""
    public var nn = ""
    public var level = 0
    
    init(v: JSON) {
        self.type = v["type"].stringValue
        self.content = v["data"]["content"].stringValue
        self.nn = v["data"]["from"]["nickName"].stringValue
        self.level = v["data"]["from"]["level"].intValue
    }
}
