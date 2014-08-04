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
        
        // From the web
        println("Load in some JSON from a get request")
        var url = "https://itunes.apple.com/search?term=ANTEMASQUE&media=music&entity=song"
        var getTracksRequest = SwiftNetworkingClient.get(url).onComplete({result -> Void in
            /*var parsedSongs = parseJSON(result)["results"]
            println(parsedSongs)
            
            var parsedSongsArr = parsedSongs!
            
            for song : [String: JSONVal] in parsedSongsArr {
                println(song)
            }*/
            
            var songs = parseJSON(result)["results"]
            //var songsArr = songs.val() as [String : Any]
            var songsArr = songs.val()
            println(songsArr)
            //for song in songsArr {
            //    println(song)
            //}
            
            
        }).onError({error -> Void in
            println("ERROR RECEIVED")
        })
        
        getTracksRequest.go()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


}

