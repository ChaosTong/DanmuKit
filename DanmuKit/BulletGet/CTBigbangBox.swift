//
//  CTBigbangBox.swift
//  BulletAnalyzer
//
//  Created by ChaosTong on 2017/11/20.
//  Copyright © 2017年 ChaosTong. All rights reserved.
//

import Foundation

class CTBigbangBox {
    
    
    func bigBang(_ string: String) -> [CTBigbangItem] {
        let items = [CTBigbangItem]()
        
        return items
    }
}

struct CTBigbangItem {
    var text = ""
    var isSymbolOrEmoji = false
    
    init(text: String, isSymbol: Bool) {
        self.text = text
        self.isSymbolOrEmoji = isSymbol
    }
}
