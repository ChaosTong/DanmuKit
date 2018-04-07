//
//  DMManager.swift
//  DanmuKit
//
//  Created by ChaosTong on 2018/4/5.
//  Copyright © 2018年 ChaosTong. All rights reserved.
//

import Foundation

private let shared = DMManager()

public class DMManager: NSObject {
    public class var manager: DMManager {
        return shared
    }
    public func test() {
        print("hello danmukit 22")
    }
}
