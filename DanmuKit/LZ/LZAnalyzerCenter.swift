//
//  LZAnalyzerCenter.swift
//  DanmuKit
//
//  Created by ChaosTong on 2018/4/21.
//  Copyright © 2018年 ChaosTong. All rights reserved.
//

import Foundation

public class LZAnalyzerCenter: NSObject {
    
    public class var shared: LZAnalyzerCenter {
        struct Static {
            static let instance: LZAnalyzerCenter = LZAnalyzerCenter()
        }
        return Static.instance
    }
    
    public var wordsArray = [BAWordsModel]()
    public var sentenceArray = [BASentenceModel]()
    public var popSentenceArray = [BASentenceModel]()
    var timeRepeatCount = 0
    var repeatTimer = Timer()
    var isAnalyzing = false
    
    public func beginObserving() {
        isAnalyzing = true
        NotificationCenter.default.addObserver(self, selector: #selector(bullet(_:)), name: NSNotification.Name.init("LZNotificationBullet"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(gift(_:)), name: NSNotification.Name.init("LZNotificationGift"), object: nil)
        repeatTimer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(sortData), userInfo: nil, repeats: true)
        RunLoop.current.add(repeatTimer, forMode: .commonModes)
    }
    
    public func endAnalyzing() {
        isAnalyzing = false
    }
    
    @objc func gift(_ noti: Notification) {
        if let dict = noti.userInfo {
            if let _ = dict["Gift"] as? [LZGiftModel] {
                
            }
        }
    }
    
    @objc func bullet(_ noti: Notification) {
        if let dict = noti.userInfo {
            if let array = dict["Bullet"] as? [LZBulletModel] {
                array.forEach({ (m) in
                    analyzingWords(m)
                })
            }
        }
    }
    
    @objc func sortData() {
        timeRepeatCount += 1
        DispatchQueue.global(qos: .userInitiated).async {
            
            var params = 20
            self.sentenceArray.sort(by: { $0.count > $1.count })
            self.sentenceArray.forEach( {$0.decrease()} )
            self.popSentenceArray.sort(by: { $0.realCount > $1.realCount })
            if self.popSentenceArray.count > 30 {
                self.popSentenceArray.removeSubrange(Range<Int>.init(uncheckedBounds: (lower: 30, upper: self.popSentenceArray.count - 1)))
            }
            
            params = 30
            if self.timeRepeatCount/params - self.timeRepeatCount/params == 0 {
                self.wordsArray.sort(by: { $0.count > $1.count })
            }
            if self.wordsArray.count > 60 {
                self.wordsArray.removeSubrange(Range<Int>.init(uncheckedBounds: (lower: 50, upper: self.wordsArray.count - 1)))
            }
            
            if self.popSentenceArray.count > 3 {
                for i in 0..<3 {
                    print(self.popSentenceArray[i].text,self.popSentenceArray[i].realCount)
                }
                print("最多句子------------------------")
            }
            if self.sentenceArray.count > 3 {
                for i in 0..<3 {
                    print(self.sentenceArray[i].text,self.sentenceArray[i].realCount)
                }
                print("近似度句子------------------------")
            }
            if self.wordsArray.count > 3 {
                for i in 0..<3 {
                    print(self.wordsArray[i].words,self.wordsArray[i].count)
                }
                print("关键词------------------------")
            }
            print("*****************************")
        }
    }
    
    func analyzingWords(_ bulletModel: LZBulletModel) {
        // 分词结果
        let items = GBigbangBox.bigBang(bulletModel.content) ?? [GBigbangItem]()
        
        // 词频分析
        for v in items {
            if !isIgnoreSpcificWords(v.text) && !isIgnorePureNumber(v.text) {
                var contained = false
                for (i,m) in wordsArray.enumerated() {
                    contained = m.words == v.text
                    if contained {
                        wordsArray[i].count += 1
                        break
                    }
                }
                if !contained {
                    let model = BAWordsModel.init(words: v.text, count: 1)
                    wordsArray.append(model)
                }
            }
        }
        
        // 语义分析
        let newSentence = BASentenceModel.init(text: bulletModel.content, words: items)
        newSentence.wordsArray = items
        
        var similar = false
        for s in sentenceArray {
            //计算余弦角度
            //两个向量内积
            //两个向量模长乘积
            var A: Double = 0 //两个向量内积
            var B: Double = 0 //第一个句子的模长乘积的平方
            var C: Double = 0 //第二个句子的模长乘积的平方
            for v in s.wordsDic {
                let value2 = newSentence.wordsDic[v.key]
                if let v2 = value2 {
                    A += v.value * v2
                } else {
                    A += 0
                }
                B += v.value * v.value
            }
            
            for v in s.wordsDic {
                C += v.value * v.value
            }
            
            let percent = 1 - acos(A / (sqrt(B) * sqrt(C))) / Double.pi
            
            if percent > 0.6 {
                similar = true
                s.count += 1
                s.realCount += 1
                break
            }
        }
        if !similar {
            newSentence.container = sentenceArray
            sentenceArray.append(newSentence)
            popSentenceArray.append(newSentence)
        }
    }
    
    /**
     特殊过滤词语
     */
    func isIgnoreSpcificWords(_ string: String) -> Bool {
        return string.count < 2 || string.contains("emot") || string.contains("dy") || string.contains("666")
    }
    
    /**
     检查是不是纯数字
     */
    func isIgnorePureNumber(_ string: String) -> Bool {
        let str = (string as NSString).trimmingCharacters(in: CharacterSet.decimalDigits)
        if str.count > 0 { return false }
        return true
    }
}
