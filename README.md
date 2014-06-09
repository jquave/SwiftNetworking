SwiftNetworking
===============

Some helpers for making API calls in Swift


## Usage

```swift
import SwiftNetworking
let swiftNetworking = SwiftNetworking()

```


#### `GET` Request

```swift
swiftNetworking.get("http://example.com/api.json", completionHandler: {(results: AnyObject) -> Void in
    if let dict = result as? NSDictionary {
        // Do stuff
    }
}
```


#### `POST` Request
```swift
var params = ["foo1":"bar1", "foo2":"bar2"]
swiftNetworking.post("http://example.com/api.json", params: params, completionHandler: {(result: AnyObject) -> Void in
    println(result)
})
```
