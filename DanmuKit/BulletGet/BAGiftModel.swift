//
//  BAGiftModel.swift
//  BulletAnalyzer
//
//  Created by ChaosTong on 2017/11/18.
//  Copyright © 2017年 ChaosTong. All rights reserved.
//

import Foundation

enum BAGiftType: Int {
    case FishBall = 0 //鱼丸礼物 增加体重
    case FreeGift = 1 //免费道具礼物 免费
    case CostGift = 2 //购买道具礼物 0.2鱼翅
    case DeserveLevel1 = 3 //低级酬勤 15鱼翅
    case DeserveLevel2 = 4 //中级酬勤 30鱼翅
    case DeserveLevel3 = 5 //高级酬勤 50鱼翅
    case Card = 6    //办卡 6鱼翅鱼翅
    case Plane = 7    //飞机 100鱼翅
    case Rocket = 8    //火箭/超级火箭 500-2000鱼翅
    case None = 9999 //无礼物
}

public struct BAGiftModel {
    
    public var description: String {
        if self.giftType == .Rocket { // || self.giftType == .Plane {
            if hits > 1 {
                return "\(self.sn) 送给 \(self.dn) \(self.gn) \(self.hits)连击"
            } else {
                return "\(self.sn) 送给 \(self.dn) \(self.gn)"
            }
        }
        if hits > 1 {
            if !bnn.isEmpty && bnn != "bnn" {
                return "用户等级: \(self.level) 牌子: \(self.bnn) \(self.bl)级, \(self.nn): 赠送的\(self.giftType) \(self.hits)连击"
            } else {
                return "用户等级: \(self.level), \(self.nn): 赠送的\(self.giftType) \(self.hits)连击"
            }
        } else {
            if !bnn.isEmpty && bnn != "bnn" {
                return "用户等级: \(self.level) 牌子: \(self.bnn) \(self.bl)级, \(self.nn): 赠送的\(self.giftType)"
            } else {
                return "用户等级: \(self.level), \(self.nn): 赠送的\(self.giftType)"
            }
        }
    }
    
    //礼物类型
    var giftType: BAGiftType = .None
    // 佩戴牌子名称
    var bnn = ""
    // 佩戴的牌子等级
    var bl = 1
    // 牌子房间
    var brid = ""
    //接受礼物房间id //火箭飞机则看drid
    var rid = ""
    //广播礼物的房间
    var drid = ""
    //弹幕分组 ID
    var gid = ""
    //客户端类型:默认值 0(表示 web 用户)
    var ct = 0
    //主播体重
    var dw = ""
    //特效id
    var eid = ""
    //礼物id
    var gfid = ""
    //礼物显示样式 1:鱼丸 2:怂 稳 呵呵 点赞 粉丝荧光棒 辣眼睛 3:弱鸡 5:飞机 6:火箭   2 3为道具礼物
    var gs = 9999
    //连击
    var hits = 1
    //头像
    var ic = ""
    //用户等级
    var level = 0
    //昵称
    var nn = ""
    //用户id
    var uid = ""
    //赠送火箭用户昵称
    var sn = ""
    //受赠火箭者昵称
    var dn = ""
    //礼物名称
    var gn = ""
    //礼物数量
    var gc = 0
    //1火箭 2飞机
    var es = ""
    //酬勤等级 1级 15鱼翅 2级30鱼翅 3级50鱼翅
    var lev = 0
    //用户头像小
    var iconSmall = ""
    //用户头像中
    var iconMiddle = ""
    //用户头像大
    var iconBig = ""
    //名字宽度
    var nameWidth: CGFloat = 0
    //是否是超级火箭
    var superRocket = false
    //是否是定制礼物
    var specialGift = false
    
    init(dict: Dict) {
        self.nn = dict["nn"] ?? "nn"
        self.iconSmall = dict["iconSmall"] ?? "iconSmall"
        self.gn = dict["gn"] ?? "gn"
        self.gs = Int(dict["gs"] ?? "9999") ?? 9999
        self.level = Int(dict["level"] ?? "0") ?? 0
        self.bnn = dict["bnn"] ?? "bnn"
        self.bl = Int(dict["bl"] ?? "1") ?? 1
        self.brid = dict["brid"] ?? "brid"
        self.uid = dict["uid"] ?? "uid"
        self.hits = Int(dict["hits"] ?? "1") ?? 1
        self.ct = Int(dict["ct"] ?? "0") ?? 0
        self.ic = dict["ic"] ?? "ic"
        self.dw = dict["dw"] ?? "dw"
        self.rid = dict["rid"] ?? "rid"
        self.eid = dict["eid"] ?? "eid"
        self.gfid = dict["gfid"] ?? "gfid"
        self.sn = dict["sn"] ?? "sn"
        self.dn = dict["dn"] ?? "dn"
        self.lev = Int(dict["lev"] ?? "0") ?? 0
        
        if gn.contains("超级火箭") {
            self.superRocket = true
        }
        if sn == "sn" {
            sn = nn
        }
        if ic != "ic" {
            var urlStr = (ic as NSString).replacingOccurrences(of: "@S", with: "/")
            urlStr = "https://apic.douyucdn.cn/upload/"+urlStr
            iconSmall = urlStr + "_small.jpg"
            iconMiddle = urlStr + "_middle.jpg"
            iconBig = urlStr + "_big.jpg"
        }
        
        switch self.gs {
        case 1:
            self.giftType = .FishBall
            break
        case 2,3:
            self.giftType = .FreeGift
            break
        case 4:
            self.giftType = .Card
            break
        case 5:
            self.giftType = self.gn.contains("火箭") ? .Rocket : .Plane
            break
        case 6:
            self.giftType = .Rocket
            break
        default:
            break
        }
        
        switch lev {
        case 1:
            giftType = .DeserveLevel1
            break
        case 2:
            giftType = .DeserveLevel2
            break
        case 3:
            giftType = .DeserveLevel3
            break
        default:
            break
        }
    }
}

