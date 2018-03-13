//
//  ViewController.swift
//  SwiftSocketIODemo
//
//  Created by zsk on 2018/3/13.
//  Copyright © 2018年 zsk. All rights reserved.
//

import UIKit
import SocketIO

class ViewController: UIViewController {
    var manager: SocketManager!

    override func viewDidLoad() {
        super.viewDidLoad()
        // 本地：http://localhost:3000
        // 远程：https://streamer.cryptocompare.com/
        manager = SocketManager(socketURL: URL(string: "http://localhost:3000")!, config: [.log(false), .compress])
        
        let socket = manager.defaultSocket
        
        socket.on(clientEvent: .connect) { (data, ack) in
            print("socket Connected \(data)")
            //socket.emit("SubAdd", with: [["subs": ["5~CCCAGG~BTC~USD"]]])
            socket.emit("ToMessage", with: ["你好，服务器"])
        }
        
        socket.on(clientEvent: .disconnect) { (data, ack) in
            print("socket disconnect \(data)")
        }
        
        socket.on(clientEvent: .statusChange) { (data, ack) in
            print("socket statusChange \(data)")
        }
        
        socket.on(clientEvent: .error) { (data, ack) in
            print("socket error \(data)")
        }
        
        socket.on("message") { (data, ack) in
            print("socket message \(data)")
        }
        
        socket.on("m") { (data, ack) in
            print("===================socket m \(data)")
        }
        
        socket.connect()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

