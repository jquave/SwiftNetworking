//
//  ViewController.swift
//  SwiftNetworkingExample
//
//  Created by Jameson Quave on 7/27/14.
//  Copyright (c) 2014 JQ Software. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
                            
    override func viewDidLoad() {
        super.viewDidLoad()

        
        /*
        {
            "key": "value",
            "arrayOfStuff": [
            1,
            2
            ],
            "dict": {
                "key": "value",
                "key2": "value2"
            }
        }*/
        let jsonMixed = "{\"key\": \"value\",\"arrayOfStuff\": [1,2],\"dict\": {\"key\": \"value\",\"key2\": \"value2\"}}"

        var parsedMixed = JSON(jsonMixed).parse()


        // Succeed
        println(parsedMixed["key"])
        println(parsedMixed["arrayOfStuff"])
        println(parsedMixed["arrayOfStuff"][0])
        println(parsedMixed["dict"])
        println(parsedMixed["dict"]["key"])
        
        // Fail
        println(parsedMixed["invalidKey"])
        println( parsedMixed["invalidKey"][0]["None Of this exists"] )
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

