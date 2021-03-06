SwiftNetworking
===============

Some helpers for making API calls in Swift


## Usage

#### `GET` Request With JSON Parsing

```swift

SwiftNetworkingClient.get(url).onComplete({result -> Void in
    var parsedSongs = parseJSON(result)["results"]
    println(parsedSongs)
    
    
}).onError({error -> Void in
    println("ERROR RECEIVED")
})

```

### `POST` Request
```swift
SwiftNetworkingClient.post("http://localhost:3000/api/register", params: ["username":"something", "token":"something"] ).onComplete({results -> Void in
  println(results)
}).onError({error -> Void in
  println("Error!")
})
```


### JSON Parsing
```swift
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
```
