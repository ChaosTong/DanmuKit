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
        case _ as [String: Any]:
            valueString = JSON.init(value).description
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

extension String {
    func subString(from startString: String, to endString: String) -> String {
        var str = self
        if let startIndex = self.range(of: startString)?.upperBound {
            str.removeSubrange(str.startIndex ..< startIndex)
            if let endIndex = str.range(of: endString)?.lowerBound {
                str.removeSubrange(endIndex ..< str.endIndex)
                return str
            }
        }
        return ""
    }
    
    func subString(from startString: String) -> String {
        var str = self
        if let startIndex = self.range(of: startString)?.upperBound {
            str.removeSubrange(self.startIndex ..< startIndex)
            return str
        }
        return ""
    }
    
    
    func delete(between startString: String, and endString: String) -> String {
        var str = self
        if let start = self.range(of: startString), let end = self.range(of: endString) {
            str.removeSubrange(start.upperBound ..< end.lowerBound)
            return str
        }
        return ""
    }
    
    //MARK: - String Path
    var pathComponents: [String] {
        get {
            return (self.standardizingPath as NSString).pathComponents
        }
    }
    
    var lastPathComponent: String {
        get {
            return (self as NSString).lastPathComponent
        }
    }
    
    var standardizingPath: String {
        get {
            return (self as NSString).standardizingPath
        }
    }
    
    mutating func deleteLastPathComponent() {
        self = (self.standardizingPath as NSString).deletingLastPathComponent
    }
    
    mutating func deletePathExtension() {
        self = (self.standardizingPath as NSString).deletingPathExtension
    }
    
    mutating func appendingPathComponent(_ str: String) {
        self = (self.standardizingPath as NSString).appendingPathComponent(str)
    }
    
    func isChildPath(of url: String) -> Bool {
        guard self.pathComponents.count > url.pathComponents.count else {
            return false
        }
        var t = self.pathComponents
        t.removeSubrange(url.pathComponents.count ..< self.pathComponents.count)
        return t == url.pathComponents
    }
    
    func isChildItem(of url: String) -> Bool {
        var pathComponents = self.pathComponents
        pathComponents.removeLast()
        return pathComponents == url.pathComponents
    }

    var isUrl: Bool {
        get {
            do {
                let detector = try NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
                let matches = detector.matches(in: self, options: [], range: NSRange(location: 0, length: self.utf16.count))
                return matches.count == 1
            } catch {
                return false
            }
        }
    }
}
