//
//  QJSON.swift
//  AccessControl
//
//  Created by Jameson Quave on 7/25/14.
//  Copyright (c) 2014 JQ Software. All rights reserved.
//

import Foundation

func parseJSON(data: NSData) -> JSONVal {
    return JSON(data).parse()
}

func parseJSON(str: String) -> JSONVal {
    return JSON(str).parse()
}

public enum JSONVal : Printable {
    
    // Generator protocol, use for `for x in y`
//    typealias Element
    /*public func next() -> JSONVal? {
        return self
    }
    typealias GeneratorType = JSONVal
    */
    
    /*
protocol Sequence {
typealias GeneratorType : Generator
func generate() -> GeneratorType
}
*/
    /*typealias GeneratorType = JSONVal
    func generate() -> GeneratorType {
        return GeneratorType(0)
    }
    func next() -> JSONVal {
        return JSONVal("hi")
    }
    */
    
    public func val() -> Any {
        switch self {
        case .Dictionary(let dict):
            return dict
        case .JSONDouble(let d):
            return d
        case .JSONInt(let i):
            return i
        case .JSONArray(let arr):
            return arr
        case .JSONStr(let str):
            return str
        case .JSONBool(let jbool):
            return jbool
        case .Null:
            return "Null"
        }
    }
    
    case Dictionary([String : JSONVal])
    case JSONDouble(Double)
    case JSONInt(Int)
    case JSONArray([JSONVal])
    case JSONStr(String)
    case JSONBool(Bool)
    case Null
    
    
    // Pretty prints for Dictionary and Array
    
    func pp(data : [String : JSONVal]) -> String {
        return "DICT"
    }
    
    func pp(data : [JSONVal]) -> String {
        var str = "[\n"
        var indentation = "  "
        for x : JSONVal in data {
            str += "\(indentation)\(x)\n"
        }
        return str
    }
    
    public var description: String {
        switch self {
        case .Dictionary(let dict):
            var str = "{\n"
            var indent = "  "
            for (key,val) in dict {
                str += "\(indent)\(key):  \(val)\n"
            }
            return "JSONDictionary \(str)"
        case .JSONDouble(let d):
            return "\(d)"
        case .JSONInt(let i):
            return "\(i)"
        case .JSONArray(let arr):
            var str = "[\n"
            var num = 0
            var indent = "  "
            for object in arr {
                str += "[\(num)]\(indent)\(object.description)\n"
                num++
            }
            str += "]"
            return "JSONArray [\(arr.count)]: \(str)"
        case .JSONStr(let str):
            return str
        case .JSONBool(let jbool):
            return "\(jbool)"
        case .Null:
            return "Null"
        }
    }
    
    subscript(index: String) -> JSONVal {
        switch self {
            case .Dictionary(let dict):
                if dict[index]? {
                    return dict[index]!
                }
                return JSONVal("JSON Fault")
            
            default:
                println("Element is not a dictionary")
                return JSONVal("JSON Fault")
        }
    }
    
    subscript(index: Int) -> JSONVal {
        switch self {
            case .JSONArray(let arr):
                return arr[index]
            default:
                println("Element is not an array")
                return JSONVal("JSON Fault")
        }
    }
    
    init(_ json: Int) {
        self = .JSONInt(json)
    }
    
    init(_ json: AnyObject) {

        if let jsonDict = json as? NSDictionary {
                var kvDict = [String : JSONVal]()
                for (key: AnyObject, value: AnyObject) in jsonDict {
                    if let keyStr = key as? String {
                        kvDict[keyStr] = JSONVal(value)
                    }
                    else {
                        println("Error: key in dictionary is not of type String")
                    }
                }
                self = .Dictionary(kvDict)
        }
        else if let jsonDouble = json as? Double {
            self = .JSONDouble(jsonDouble)
        }
        else if let jsonInt = json as? Int {
            self = .JSONInt(jsonInt)
        }
        else if let jsonBool = json as? Bool {
            self = .JSONBool(jsonBool)
        }
        else if let jsonStr = json as? String {
            self = .JSONStr(jsonStr)
        }
        else if let jsonArr = json as? NSArray {
            var arr = [JSONVal]()
            
            for val in jsonArr {
                arr += JSONVal(val)
            }
            
            self = .JSONArray( arr )
        }
        else {
            println("ERROR: Couldn't convert element \(json)")
            self = .Null
        }

    }
}

public class JSON {
    
    public var json = ""
    public var data: NSData
    
    init(_ json: String) {
        self.json = json
        self.data = json.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!
    }
    
    init(_ data: NSData) {
        self.json = ""
        self.data = data
        //self.data = self.json.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
    }

    public func parse() -> JSONVal {
        var err: NSError? = nil
        var val = JSONVal(NSJSONSerialization.JSONObjectWithData(self.data, options: nil, error: &err))
        
        return val
    }
    
    
    public class func encodeAsJSON(data: AnyObject!) -> String? {
        var json = ""
        
        if let rootObjectArr = data as? [AnyObject] {
            // Array
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
            return escape(rootObjectStr)
        }
        else if let rootObjectDictStrStr = data as? Dictionary<String, String> {
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
    
    class func escape(str: String) -> String {
        var newStr = str.stringByReplacingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
        // Replace already escaped quotes with non-escaped quotes
        newStr = newStr.stringByReplacingOccurrencesOfString("\\\"", withString: "\"")
        // Escape all non-escaped quotes
        newStr = newStr.stringByReplacingOccurrencesOfString("\"", withString: "\\\"")
        return "\"\(newStr)\""
    }
    
    
}