//
//  BASentenceModel.swift
//  BulletAnalyzer
//
//  Created by ChaosTong on 2017/11/19.
//  Copyright © 2017年 ChaosTong. All rights reserved.
//

import Foundation

public class BASentenceModel {
    /**
     句子文本
     */
    public var text = ""

    /**
     分词数组
     */
    public var wordsArray: [GBigbangItem] {
        didSet {
            var wordsDict: Dictionary<String,Double> = [:]
            for (i, v) in wordsArray.enumerated() {
                if let _ = wordsDict[v.text] {} else {
                    var count: Double = 1
                    for (ii ,vv) in wordsArray.enumerated() {
                        if v.text == vv.text && i != ii {
                            count += 1
                        }
                    }
                    wordsDict[v.text] = count
                }
            }
            self.wordsDic = wordsDict
        }
    }

    /**
     词频向量字典 key为词 value为次数
     */
    var wordsDic: Dictionary<String,Double> = [:]

    /**
     相似的句子有多少个 //会递减
     */
    public var count: Int {
        didSet {
            if count <= 0 && container.count > 0 {
                container.removeAll()
            }
        }
    }

    /**
     相似的句子有多少个 //不会递减
     */
    public var realCount = 0

    /**
     存放自己的数组
     */
    var container = [BASentenceModel]()

    /**
     排行
     */
    var index = 0

    /**
     count减一
     */
    func decrease() {
        count -= (count / 10) - 1
    }

    /**
     快速构造句子对象
     
     @param text 句子
     @param wordsArray 句子分词数组
     @return 构造好的对象
     */
    init(text: String, words: [GBigbangItem]) {
        self.text = text
        self.wordsArray = words
        self.count = 1
        self.realCount = 1
    }
}
