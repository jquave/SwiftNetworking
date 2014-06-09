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


class SwiftNetworkingClient {
    
    var deserializationMethod = DeserializationMethod.JSON
    var parameterEncordingMethod = ParameterEncodingMethod.Form
    
    var completionHandler: ((AnyObject) -> (Void))?
    var errorCompletionHandler: ((NSError) -> (Void))?
    
    var path: String?
    var method: String?
    var params: Dictionary<String, String>?

    init(path: String, method: String) {
        self.path = path
        self.method = method
    }
    
    class func get(path: String) -> SwiftNetworkingClient {
        return SwiftNetworkingClient(path: path, method: "GET")
    }
    
    class func post(path: String, params: Dictionary<String, String>?) -> SwiftNetworkingClient {
        var newClient = SwiftNetworkingClient(path: path, method: "POST")
        newClient.params = params
        return newClient
    }
    
    func perform() {
        let url = NSURL(string: path)
        var request = NSMutableURLRequest(URL: url)
        
        
        
        request.HTTPMethod = self.method
        
        if self.method=="POST" {
            // Encode parameters
            var paramsStr = encodeAsJSON(self.params)
            request.HTTPBody = paramsStr?.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        }
        
        
        println("Get \(self.method)")
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: {(response: NSURLResponse!,data: NSData!,error: NSError!) -> Void in
            if error? {
                println("ERROR: \(error.localizedDescription)")
                if let cOnError = self.errorCompletionHandler {
                    cOnError(error!)
                }
            }
            else {
                var error: NSError?
                var jsonResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &error) as? NSDictionary
                
                // Now send the JSON result to our delegate object
                if error? {
                    println("HTTP Error: \(error?.localizedDescription)")
                    if let cOnError = self.errorCompletionHandler {
                        cOnError(error!)
                    }
                }
                else {
                    println("Results recieved")
                    if jsonResult? {
                        self.completionHandler!(jsonResult!)
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
            json = "\(json)["
            for embeddedObject: AnyObject in rootObjectArr {
                var encodedEmbeddedObject = encodeAsJSON(embeddedObject)
                if encodedEmbeddedObject? {
                    json = "\(json)\(encodedEmbeddedObject!),"
                }
                else {
                    println("Error creating JSON")
                    return nil
                }
            }
            json = "\(json)]"
        }
        else if let rootObjectStr = data as? String {
            // This is a string, just return it
            println("Found a string")
            return escape(rootObjectStr)
        }
        else if let rootObjectDictStrStr = data as? Dictionary<String, String> {
            println("Found a Dictionary")
            json = "\(json){"
            var numKeys = rootObjectDictStrStr.count
            var keyIndex = 0
            for (key,value) in rootObjectDictStrStr {
                
                // This could be a number
                
                if(keyIndex==(numKeys-1)) {
                    json = json.stringByAppendingString("\(escape(key)):\(escape(value))")
                }
                else {
                    json = json.stringByAppendingString("\(escape(key)):\(escape(value)),")
                }
                keyIndex = keyIndex + 1
            }
            json = "\(json)}"
        }
        else {
            println("Failed to write JSON object")
            return nil
        }
        
        return json
    }
    
    func onComplete( completionHandler:((AnyObject) -> Void)? ) -> SwiftNetworkingClient {
        self.completionHandler = completionHandler
        perform()
        return self
    }
    
    func onError( completionHandler:((AnyObject) -> Void)? ) -> SwiftNetworkingClient {
        self.errorCompletionHandler = completionHandler
        return self
    }
    
    
}