//
//  PDTransModelTool.swift
//  DanmuKit
//
//  Created by ChaosTong on 2018/4/7.
//  Copyright © 2018年 ChaosTong. All rights reserved.
//

import Foundation

class PDTransModelTool {

    func transModelWithContents(data: Data, complete: @escaping transCompleteBlock) {
        
        var contents = [JSON]()
        let subData = (data as NSData).copy()
        var _location = 0
        var _length = 0
        repeat {
            _length = data.count
//            print("data length is:---\(_length)")
            
            if ((subData as AnyObject).length < 6) {
                print("--- error subData length error end")
                return
            }
            _location += 4
            // MARK: - [) 取出消息体1长度
            let msg1_length_data = data.subdata(in: _location..<_location+2)
            let index_1 = Int(msg1_length_data[0])
            let index_2 = Int(msg1_length_data[1])
            let msg1_length = (index_1 * 16 + index_2)
            _location += 2
            _location += msg1_length
            // MARK: - [) 取出消息体2长度
            let msg2_length_data = data.subdata(in: _location..<_location+4)
            let index_3 = Int(msg2_length_data[0])
            let index_4 = Int(msg2_length_data[1])
            let index_5 = Int(msg2_length_data[2])
            let index_6 = Int(msg2_length_data[3])
            let msg2_length = (index_3 * 16 * 16 * 256 + index_4 * 16 * 16 * 16 +
                index_5 * 16 * 16 + index_6)
            if (msg2_length > 0 && msg2_length < data.count) {} else {
//                print(subData as! NSData)
                return
            }
            _location += 4
            
            let main_data = data.subdata(in: _location+16..<_location+msg2_length)
            
            guard String(data: main_data, encoding: .utf8) != nil  else {
                print("--- error length error");return
            }
            let json = JSON(data: main_data)
            _location += msg2_length
            contents.append(json)
        } while (_location < _length)
        
        var bulletArray = [PDBulletModel]()
        
        for v in contents {
            let type = v["type"].stringValue
            if type == "1" {
                let m = PDBulletModel.init(v: v)
                bulletArray.append(m)
            }
        }
        
        if bulletArray.count > 0 {
            complete(bulletArray, .Bullet)
        }
    }
    
}
