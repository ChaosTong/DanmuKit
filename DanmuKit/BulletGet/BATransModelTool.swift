//
//  BATransModelTool.swift
//  BulletAnalyzer
//
//  Created by ChaosTong on 2017/11/16.
//  Copyright © 2017年 ChaosTong. All rights reserved.
//

import Foundation

enum BAModelType: Int {
    case Bullet = 0 //模型数据类型为弹幕
    case Reply = 1  //模型数据类型为服务器回复
    case Gift = 2   //模型数据类型为礼物
}

typealias transCompleteBlock = (_ array: Array<Any>, _ modelType: BAModelType) -> ()
typealias transArrayCompleteBlock = Array
typealias transModelCompleteBlock = Any

class BATransModelTool {
    
    func transModelWithData(data: Data, ignoreFreeGift: Bool, complete: @escaping transCompleteBlock) {
        var contents = [String]()
        var subData = (data as NSData).copy() as! NSData
        var _location = 0
        var _length = 0
        repeat {
            //前12字节: 4长度+4长度+2类型+2保留
            _location += 12
            //获取数据长度
            subData.getBytes(&_length, range: NSMakeRange(0, 4))
            _length -= 8
            //截取相对应的数据
            if _length <= subData.length - 12 && _length > 0 {
                let contentData = subData.subdata(with: NSMakeRange(12, _length))
                let content = NSString.init(data: contentData, encoding: String.Encoding.utf8.rawValue)
                subData = (data as NSData).subdata(with: NSMakeRange(_length+_location, data.count-_length-_location)) as NSData
                if let c = content {
                    if c.length > 0 {
                        contents.append(c as String)
                    }
                }
                _location += _length
            }
            
        } while ( _location < data.count && subData.length > 12 )
        
        transModelWithContents(contents: contents, ignoreFreeGift: ignoreFreeGift) { (array, modelType) in
            complete(array, modelType)
        }
    }
    
    func transModelWithContents(contents: [String], ignoreFreeGift: Bool, complete: @escaping transCompleteBlock) {
     
        var bulletArray = [BABulletModel]()
        var giftArray = [BAGiftModel]()
        var replyArray = [BAReplyModel]()
        
        contents.forEach { (obj) in
            let dict = obj.stringDict
            if dict["type"] == BAInfoType.Bullet.rawValue {
                let bulletModel = BABulletModel.init(dict: dict)
                bulletArray.append(bulletModel)
            } else if dict["type"] == BAInfoType.SmallGift.rawValue || dict["type"] == BAInfoType.DeserveGift.rawValue || dict["type"] == BAInfoType.SuperGift.rawValue {
                let giftModel = BAGiftModel.init(dict: dict)
                if ignoreFreeGift {
                    if giftModel.giftType != .None && giftModel.giftType != .FreeGift {
                        giftArray.append(giftModel)
                    }
                } else {
                    giftArray.append(giftModel)
                }
            } else if dict["type"] == BAInfoType.LoginReply.rawValue {
                let replayModel = BAReplyModel.init(dict: dict)
                replayModel.type = BAInfoType.LoginReply
                replyArray.append(replayModel)
            }
        }
        if bulletArray.count > 0 {
            complete(bulletArray, .Bullet)
        }
        if giftArray.count > 0 {
            complete(giftArray, .Gift)
        }
        if replyArray.count > 0 {
            complete(replyArray, .Reply)
        }
    }
    
}
