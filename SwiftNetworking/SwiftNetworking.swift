//
//  SwiftNetworking.swift
//  SwiftNetworking
//
//  Created by Jameson Quave on 6/8/14.
//  Copyright (c) 2014 JQ Software LLC. All rights reserved.
//

import Foundation

enum DeserializationMethod: Int {
    case JSON
}

enum ParameterEncodingMethod: Int {
    case JSON, Form
}

class SwiftNetworking {
    
    var deserializationMethod = DeserializationMethod.JSON
    var parameterEncordingMethod = ParameterEncodingMethod.Form

    func get(path: String, completionHandler: ((AnyObject) -> Void)?) {
        let url = NSURL(string: path)
        let request = NSURLRequest(URL: url)
        
        println("Get \(path)")
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: {(response: NSURLResponse!,data: NSData!,error: NSError!) -> Void in
            if error? {
                println("ERROR: \(error.localizedDescription)")
            }
            else {
                var error: NSError?
                var jsonResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &error) as? NSDictionary
                
                
                jsonResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &error) as? NSDictionary
                
                // Now send the JSON result to our delegate object
                if error? {
                    println("HTTP Error: \(error?.localizedDescription)")
                }
                else {
                    println("Results recieved")
                    if jsonResult? {
                        completionHandler!(jsonResult!)
                    }
                }
            }
        })
    }
    
    func escape(str: String) -> String {
        var newStr = str.stringByReplacingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
        // Replace already escaped quotes with non-escaped quotes
        newStr = newStr.stringByReplacingOccurrencesOfString("\\\"", withString: "\"")
        // Escape all non-escaped quotes
        newStr = newStr.stringByReplacingOccurrencesOfString("\"", withString: "\\\"")
        return "\"\(newStr)\""
    }
    
    func encodeAsJSON(data: AnyObject!) -> String? {
        var json = ""
        
        if let rootObjectArr = data as? AnyObject[] {
            // Array
            println("Found an array")
            json = json.stringByAppendingString("[")
            for embeddedObject: AnyObject in rootObjectArr {
                var encodedEmbeddedObject = encodeAsJSON(embeddedObject)
                if encodedEmbeddedObject? {
                    json = json.stringByAppendingString("\(encodedEmbeddedObject!),")
                }
                else {
                    println("Error creating JSON")
                    return nil
                }
            }
            json = json.stringByAppendingString("]")
        }
        else if let rootObjectStr = data as? String {
            // This is a string, just return it
            println("Found a string")
            return escape(rootObjectStr)
        }
        else if let rootObjectDictStrStr = data as? Dictionary<String, String> {
            println("Found a Dictionary")
            json = json.stringByAppendingString("{")
            var numKeys = rootObjectDictStrStr.count
            var keyIndex = 0
            for (key,value) in rootObjectDictStrStr {
                if(keyIndex==(numKeys-1)) {
                    json = json.stringByAppendingString("\(escape(key)):\(escape(value))")
                }
                else {
                    json = json.stringByAppendingString("\(escape(key)):\(escape(value)),")
                }
                keyIndex = keyIndex + 1
            }
            json = json.stringByAppendingString("}")
        }
        else {
            println("Failed to write JSON object")
            return nil
        }
        
        return json
    }
    
    func post(path: String, params: Dictionary<String, String>, completionHandler: ((AnyObject) -> Void)?) {
        let url = NSURL(string: path)
        var request = NSMutableURLRequest(URL: url)
        
        // Encode parameters
        var paramsStr = encodeAsJSON(params)
        println("JSON: \(paramsStr)")
        
        request.HTTPMethod = "POST"
        request.HTTPBody = paramsStr?.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        
        println("Get \(path)")
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: {(response: NSURLResponse!,data: NSData!,error: NSError!) -> Void in
            if error? {
                println("ERROR: \(error.localizedDescription)")
            }
            else {
                var error: NSError?
                var jsonResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &error) as? NSDictionary
                
                
                jsonResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &error) as? NSDictionary
                
                // Now send the JSON result to our delegate object
                if error? {
                    println("HTTP Error: \(error?.localizedDescription)")
                }
                else {
                    println("Results recieved")
                    if jsonResult? {
                        completionHandler!(jsonResult!)
                    }
                }
            }
        })
    }
    
    
}