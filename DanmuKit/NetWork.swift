//
//  NetWork.swift
//  NetWork
//
//  Created by ChaosTong on 2017/4/24.
//  Copyright © 2017年 ChaosTong. All rights reserved.
//

import Foundation

public enum MethodType {
    case get
    case post
}

public class Enough: NSObject {
    public static func requestForJSON(method: MethodType, url: String, params: [String: Any]? = nil, isData: Data? = nil, headers: [String: String]? = nil, isRecur: Bool = false, finishedCallback: @escaping (_ data: JSON?, _ error: Error?) -> ()) {
        let session = URLSession.shared
        var newURL = url
        if method == .get {
            if let params = params {
                newURL += "?" + Helper.buildParams(params)
            }
        }
        var request = URLRequest.init(url: URL.init(string: newURL)!)
        request.httpMethod = method == .get ? "GET" : "POST"
        request.allHTTPHeaderFields = headers
        
        if method == .post {
            
            if let d = isData {
                request.httpBody = d
            }
            
            if let params = params {
                if isRecur { // forget what's use for
                    if let jsonData = String().dictToJsonData(params) {
                        request.httpBody = jsonData
                    }
                } else {
                    request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
                    request.httpBody = Helper.buildParams(params).data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
                }
            }
        }
        
        let dataTask = session.dataTask(with: request, completionHandler: { (data, response, error) -> Void in
            if let data = data {
                finishedCallback(JSON(data: data), error)
            } else {
                finishedCallback(nil, error)
            }
        })
        dataTask.resume()
    }
}

extension String {
    func dictToJsonData(_ dict: [String: Any]) -> Data? {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
            return jsonData
        } catch {
            return nil
        }
    }
}
