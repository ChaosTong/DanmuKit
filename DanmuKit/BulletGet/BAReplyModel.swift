//
//  BAReplyModel.swift
//  BulletAnalyzer
//
//  Created by ChaosTong on 2017/11/16.
//  Copyright © 2017年 ChaosTong. All rights reserved.
//

import Foundation

enum BAInfoType: String {
    case Bullet = "chatmsg" //弹幕
    case LoginReply = "loginres"//登录
    case SmallGift = "dgb" //一般礼物
    case DeserveGift = "bc_buy_deserve" //酬勤礼物
    case SuperGift = "spbc" //超级礼物
}

class BABasicInfoModel {
    var type: BAInfoType!
}

class BAReplyModel: BABasicInfoModel {//用户id
   var userid = ""//房间权限组
   var roomgroup = ""//平台权限组
   var pg = ""//会话id
   var sessionid = ""//用户名
   var username = ""//用户昵称
   var nickname = ""//是否已在房间签到
   var is_signed = ""//日总签到次数
   var signed_count = ""//直播状态
   var live_stat = ""//是否需要手机验证
   var npv = 0//最高酬勤等级
   var best_dlev = 0//酬勤等级
   var cur_lev = ""
    
    init(dict: Dict) {
        self.sessionid = dict["sessionid"] ?? "sessionid"
        self.username = dict["username"] ?? "username"
        userid = dict["userid"] ?? "userid"
        roomgroup = dict["roomgroup"] ?? "roomgroup"
        pg = dict["pg"] ?? ""
        nickname = dict["nickname"] ?? "nickname"
        is_signed = dict["is_signed"] ?? "is_signed"
        signed_count = dict["signed_count"] ?? "signed_count"
        live_stat = dict["live_stat"] ?? "live_stat"
        npv = Int(dict["npv"] ?? "0") ?? 0
        best_dlev = Int(dict["best_dlev"] ?? "0") ?? 0
        cur_lev = dict["cur_lev"] ?? "cur_lev"
    }
}
