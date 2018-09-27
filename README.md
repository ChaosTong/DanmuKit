# DanmuKitDemo

> 一款方便iOS/macOS接入直播平台(龙珠游戏直播/斗鱼直播/熊猫直播/企鹅电竞)弹幕的Kit，只要知道房间号，然后接收通知就好了，so fucking easy

## Usage

``` swift
import DanmuKit

NotificationCenter.default.addObserver(self, selector: #selector(bullet(_:)), name: NSNotification.Name.init("BANotificationBullet"), object: nil)
NotificationCenter.default.addObserver(self, selector: #selector(gift(_:)), name: NSNotification.Name.init("BANotificationGift"), object: nil)

NotificationCenter.default.addObserver(self, selector: #selector(lzBullet(_:)), name: NSNotification.Name.init("LZNotificationBullet"), object: nil)
NotificationCenter.default.addObserver(self, selector: #selector(lzGift(_:)), name: NSNotification.Name.init("LZNotificationGift"), object: nil)

NotificationCenter.default.addObserver(self, selector: #selector(pdBullet(_:)), name: NSNotification.Name.init("PDNotificationBullet"), object: nil)

// 斗鱼 参数 房间号
// BASocketTool.shared.connectSocketWithRoomId(roomId: "67373")
// 龙珠 参数 房间号 非链接后的，网页源码里搜roomID 才是真实房间号
// LZDMManager.manager.connectWebSocketWithRoomId(roomId: "2241164")
// 熊猫  https://riven.panda.tv/chatroom/getinfo?roomid=7000  获取房间弹幕服务器 构建
//        let dict = "{\"errno\":0,\"errmsg\":\"\",\"data\":{\"appid\":\"134224728\",\"rid\":-90335253,\"sign\":\"ac512ba66bf171998b9f747eb086d2d0\",\"authType\":\"4\",\"ts\":1523846853000,\"chat_addr_list\":[\"115.159.247.235:443\",\"118.89.11.13:8080\",\"118.89.11.13:443\",\"115.159.247.235:8080\"]}}"
//        if let jsonStr = dict.data(using: String.Encoding.utf8, allowLossyConversion: false) {
//            let json = JSON(data: jsonStr)
//            PDDManager.shared.connectSocketWithPandaInfo(info: pandaInfo.init(v: json))
//        }
```
