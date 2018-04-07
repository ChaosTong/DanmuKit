//
//  Extension+Data.swift
//  DanmuKit
//
//  Created by ChaosTong on 2018/4/7.
//  Copyright © 2018年 ChaosTong. All rights reserved.
//

import Foundation

extension Data {
    func scanValue<T>(start: Int, length: Int) -> T {
        return self.subdata(in: start..<start+length).withUnsafeBytes { $0.pointee }
    }
}
