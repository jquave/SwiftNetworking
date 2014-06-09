SwiftNetworking
===============

Some helpers for making API calls in Swift


## Usage

#### `GET` Request

```swift
SwiftNetworkingClient.get("http://example.com").onComplete({result -> Void in
  if let dict = result as? NSDictionary {
    self.delegate?.didRecieveAPIResults(dict)
  }
}).onError({error -> Void in
  println("ERROR RECEIVED")
})

```

