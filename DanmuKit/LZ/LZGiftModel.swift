//
//  LZGiftModel.swift
//  DanmuKit
//
//  Created by ChaosTong on 2018/4/7.
//  Copyright © 2018年 ChaosTong. All rights reserved.
//

import Foundation

public struct LZGiftModel {
    
    public var description: String {
        return "\(bnn),\(nn):\(content)"
    }
    
    public var type = ""
    public var content = ""
    public var bnn = ""
    public var nn = ""
    public var avatar = ""
    
    init(v: JSON) {
        self.type = v["type"].stringValue
        self.content = v["msg"]["content"].stringValue
        self.bnn = v["msg"]["medal"]["name"].stringValue
        self.nn = v["msg"]["user"]["username"].stringValue
        self.avatar = v["msg"]["user"]["avatar"].stringValue
    }
}
