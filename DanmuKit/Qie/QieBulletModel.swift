//
//  QieBulletModel.swift
//  DanmuKit
//
//  Created by ChaosTong on 2018/9/27.
//  Copyright © 2018 ChaosTong. All rights reserved.
//

import Foundation

public struct QieBulletModel {
    
    public var description: String {
        return "\(nn):\(content)"
    }
    
    public var type = 0
    public var content = ""
    public var nn = ""
    public var level = 0
    public var zl = ""
    public var zn = ""
    
    init(v: JSON) {
        self.type = v["type"].intValue
        self.content = v["content"].stringValue
        self.nn = v["nick"].stringValue
        self.level = v["ext"]["lv"].int ?? 0
        self.zl = v["ext"]["zl"].string ?? ""
        self.zn = v["ext"]["zn"].string ?? ""
    }
}
