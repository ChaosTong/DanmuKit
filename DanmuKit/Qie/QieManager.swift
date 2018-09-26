//
//  QieManager.swift
//  DanmuKit
//
//  Created by ChaosTong on 2018/9/26.
//  Copyright © 2018 ChaosTong. All rights reserved.
//

import Foundation

let MAXRESETCOUNT: Int = 10

public class QieManager: NSObject {
    
    private let url = "https://wdanmaku.egame.qq.com/cgi-bin/pgg_barrage_async_fcgi"
    private var anchor_id = 0
    private var vid = ""
    private var roomid = ""
    private var last_tm = 0
    private var isOnline = false
    private var resetFlag = 0
    private var heartbeatTimer: DispatchSourceTimer! = DispatchSource.makeTimerSource(flags:DispatchSource.TimerFlags.init(rawValue: 0) , queue: nil)
    
    public class var shared: QieManager {
        struct Static {
            static let instance: QieManager = QieManager()
        }
        return Static.instance
    }
    
    private func getVid(_ roomid: String, finishedCallback: @escaping  (_ done: Bool?) -> ()) {
        let params = "param={\"0\":{\"module\":\"pgg_live_read_svr\",\"method\":\"get_live_and_profile_info\",\"param\":{\"anchor_id\":\(roomid),\"layout_id\":\"hot\",\"index\":0,\"other_uid\":0}}}&app_info={\"platform\":4,\"terminal_type\":2,\"egame_id\":\"egame_official\"}"
        Enough.requestForJSON(method: .post, url: "https://share.egame.qq.com/cgi-bin/pgg_live_async_fcgi?&cgi_module=pgg_live_read_svr&cgi_method=get_live_and_profile_info", isData: params.data(using: String.Encoding.utf8)) { (json, error) in
            if let _ = error { return }
            guard let json = json else { return }
            guard let vid = json["data"]["0"]["retBody"]["data"]["video_info"]["pid"].string else { return }
            guard let anchor_id = json["data"]["0"]["retBody"]["data"]["video_info"]["anchor_id"].int else { return }
            guard let endTime = json["data"]["0"]["retBody"]["data"]["video_info"]["end_tm"].int else { return }
            if (endTime == 0) { // 正在直播 无本次下播时间 == 0
                self.isOnline = true
            } else {
               print("下播了")
            }
            self.vid = vid
            self.anchor_id = anchor_id
            finishedCallback(true)
        }
    }
    
    public func linkQie(_ roomid: String) {
        self.roomid = roomid
        self.getVid(roomid) { (done) in
            if let done = done, done == true {
                self.startHeartbeat()
            }
        }
    }
    
    private func startHeartbeat() {
        heartbeatTimer.schedule(deadline: DispatchTime.now(), repeating: 1.0)
        heartbeatTimer.setEventHandler {
            self.heartBeat()
        }
        heartbeatTimer.resume()
    }
    
    public func cutoff() {
        print("断开链接")
        if heartbeatTimer != nil { heartbeatTimer.suspend() }
    }
    
    @objc private func heartBeat() {
        let params: [String: Any] = [ "param": ["0": ["module": "pgg_live_barrage_svr", "method": "get_barrage", "param": ["anchor_id": anchor_id, "vid": vid, "last_tm": last_tm, "other_uid": 0]]], "app_info": ["platform": 2, "terminal_type": 4, "version_code": 0, "version_name": 0, "pvid": 5459329024, "ssid": 518073344, "imel": 0]]
        
        Enough.requestForJSON(method: .get, url: url, params: params) { (json, error) in
            if let _ = error { return }
            guard let json = json else { return }
            guard let last_tm = json["data"]["0"]["retBody"]["data"]["last_tm"].int else { return }
            guard let msg_list = json["data"]["0"]["retBody"]["data"]["msg_list"].array else { return }
            self.last_tm = last_tm
            if (msg_list.count == 0 && self.isOnline) {
                self.resetFlag += 1
            } else if self.isOnline {
                self.resetFlag = 0
            }
            if self.resetFlag > MAXRESETCOUNT {
                self.cutoff()
                self.linkQie(self.roomid)
            }
            msg_list.forEach({ (json) in
                print(json["nick"].stringValue,json["content"].stringValue, "\n")
            })
        }
    }
}
