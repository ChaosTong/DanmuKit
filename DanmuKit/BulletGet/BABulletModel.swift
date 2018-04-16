//
//  BABulletModel.swift
//  BulletAnalyzer
//
//  Created by ChaosTong on 2017/11/18.
//  Copyright © 2017年 ChaosTong. All rights reserved.
//

import Foundation

public struct BABulletModel {
    
    public var description: String {
        return "用户等级: \(self.level) 牌子: \(self.bnn)-\(self.bl), \(self.nn): \(self.txt) 颜色是 \(self.col)"
    }
    
    // 佩戴牌子名称
    public var bnn = ""
    // 佩戴的牌子等级
    public var bl = 1
    // 牌子房间
    public var brid = ""
    //弹幕组 id
    public var gid = ""
    //房间 id
    public var rid = ""
    //发送者 id
    public var uid = ""
    //发送者昵称
    public var nn = ""
    //文本内容
    public var txt = ""
    //弹幕id
    public var cid = ""
    //用户等级
    public var level = 0
    //礼物头衔 默认0
    public var gt = ""
    //客户端类型:默认值 0(表示 web 用户)
    public var ct = 0
    //用户头像(猜想)
    public var ic = ""
    //用户头像小
    public var iconSmall = ""
    //用户头像中
    public var iconMiddle = ""
    //用户头像大
    public var iconBig = ""
    //弹幕内容
    public var bulletContent = ""
    //弹幕内容高度
    public var bulletContentHeight: CGFloat = 0
    //是否被关注
    public var notice = false
    //弹幕颜色
    public var col = 0
    // 贵族等级 1-7 游侠 骑士 子爵 伯爵 公爵 国王 皇帝
    public var nl = 0
    // 以下是不清楚属性
    public var dlv = 0
    public var dc  = 0
    public var bdlv = 0
    public var ifs = 0
    
    public var color = SWColor.black
    
    init(dict: Dict) {
        self.nn = dict["nn"] ?? "nn"
        self.txt = dict["txt"] ?? "txt"
        self.level = Int(dict["level"] ?? "0") ?? 0
        self.ic = dict["ic"] ?? "ic"
        self.gid = dict["gid"] ?? "gid"
        self.bnn = dict["bnn"] ?? "bnn"
        self.bl = Int(dict["bl"] ?? "1") ?? 1
        self.brid = dict["brid"] ?? "brid"
        ct = Int(dict["ct"] ?? "0") ?? 0
        rid = dict["rid"] ?? "rid"
        uid = dict["uid"] ?? "uid"
        cid = dict["cid"] ?? "cid"
        col = Int(dict["col"] ?? "0") ?? 0
        nl = Int(dict["nl"] ?? "0") ?? 0
        dlv = Int(dict["dlv"] ?? "0") ?? 0
        bdlv = Int(dict["bdlv"] ?? "0") ?? 0
        dc = Int(dict["dc"] ?? "0") ?? 0
        ifs = Int(dict["ifs"] ?? "0") ?? 0
        
        if ic != "ic" {
            var urlStr = (ic as NSString).replacingOccurrences(of: "@S", with: "/")
            urlStr = "https://apic.douyucdn.cn/upload/"+urlStr
            iconSmall = urlStr + "_small.jpg"
            iconMiddle = urlStr + "_middle.jpg"
            iconBig = urlStr + "_big.jpg"
        }
        
        switch col {
        case 1:
            color = SWColor.init(hexString: "FF2D2D")!
            break
        case 2:
            color = SWColor.init(hexString: "00ccff")!
            break
        case 3:
            color = SWColor.init(hexString: "9AFF02")!
            break
        case 4:
            color = SWColor.yellow
            break
        case 5:
            color = SWColor.init(hexString: "BF3EFF")!
            break
        case 6:
            color = SWColor.init(hexString: "FF60AF")!
            break
        default:
            break
        }
    }
}
