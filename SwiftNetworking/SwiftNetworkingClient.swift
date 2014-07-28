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
    
    var completionHandler: ((String) -> (Void))?
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
            var paramsStr = JSON.encodeAsJSON(self.params)
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
                var str = NSString(data: data, encoding: NSUTF8StringEncoding)
                self.completionHandler!(str)
            }
        })
    }
    
    func onComplete( completionHandler:((String) -> Void)? ) -> SwiftNetworkingClient {
        self.completionHandler = completionHandler
        perform()
        return self
    }
    
    func onError( completionHandler:((AnyObject) -> Void)? ) -> SwiftNetworkingClient {
        self.errorCompletionHandler = completionHandler
        return self
    }
    
    
}