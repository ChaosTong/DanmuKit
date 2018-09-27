//
//  Helper.swift
//  NetWork
//
//  Created by ChaosTong on 2017/4/24.
//  Copyright © 2017年 ChaosTong. All rights reserved.
//

import Foundation

public class Helper {
    // stolen from Alamofire
    static func buildParams(_ parameters: [String: Any]) -> String {
        var components: [(String, String)] = []
        for key in Array(parameters.keys).sorted(by: <) {
            let value = parameters[key]
            components += queryComponents(key, value ?? "value_is_nil")
        }
        return components.map{"\($0)=\($1)"}.joined(separator: "&")
    }
    // stolen from Alamofire
    static func queryComponents(_ key: String, _ value: Any) -> [(String, String)] {
        var components: [(String, String)] = []
        var valueString = ""
        
        switch value {
        case _ as String:
            valueString = value as! String
        case _ as Bool:
            valueString = (value as! Bool).description
        case _ as Double:
            valueString = (value as! Double).description
        case _ as Int:
            valueString = (value as! Int).description
        default:
            break
        }
        
        components.append(contentsOf: [(escape(key), escape(valueString))])
        return components
    }
    
    static func escape(_ string: String) -> String {
        let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
        let subDelimitersToEncode = "!$&'()*+,;="
        var allowedCharacterSet = CharacterSet.urlQueryAllowed
        allowedCharacterSet.remove(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")
        var escaped = ""
        if #available(iOS 8.3, *) {
            escaped = string.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet) ?? string
        } else {
            let batchSize = 50
            var index = string.startIndex
            while index != string.endIndex {
                let startIndex = index
                let endIndex = string.index(index, offsetBy: batchSize, limitedBy: string.endIndex) ?? string.endIndex
                let range = startIndex..<endIndex
                let substring = string.substring(with: range)
                escaped += substring.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet) ?? substring
                index = endIndex
            }
        }
        return escaped
    }
}
