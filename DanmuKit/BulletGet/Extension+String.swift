//
//  Extension+String.swift
//  BulletAnalyzer
//
//  Created by ChaosTong on 2017/11/16.
//  Copyright © 2017年 ChaosTong. All rights reserved.
//

import Foundation
#if os(iOS) || os(watchOS) || os(tvOS)
    import UIKit
#elseif os(OSX)
    import AppKit
#endif

typealias Dict = [String: String]

extension String {
    var packToData: Data  {
        let data = self.data(using: String.Encoding.utf8)
        let hexLength = self.count + 9
        let kPostCode1: UInt32 = 0x2b1
        var pack = postPack.init(length: UInt32(hexLength), lengthTwice: UInt32(hexLength), postCode: kPostCode1)
        var postData = Data.init(bytes: &pack, count: MemoryLayout.size(ofValue: pack))
        postData.append(data!)
        var kEnd1: UInt8 = 0
        postData.append(&kEnd1, count: 1)
        return postData
    }
    var timeString: String {
        let dat = Date(timeIntervalSinceNow: 0)
        let a = dat.timeIntervalSince1970
        let timeString = Int(a)
        return timeString.description
    }
    
    var stringDict: Dict {
        let string = (self as NSString).substring(to: self.count - 1)
        let strArray = string.components(separatedBy: "/")
        var dic: Dict = [:]
        for (_,v) in strArray.enumerated() {
            let tempArray = v.components(separatedBy: "@=")
            if let value: String = tempArray.last, let key = tempArray.first {
                dic[key] = value
            }
        }
        return dic
    }
    var packToPanda: Data {
        let data = self.data(using: .utf8)!.map{ String(format:"%02x", $0) }.joined().data(using: .utf8)!
        
        return data
    }
}
