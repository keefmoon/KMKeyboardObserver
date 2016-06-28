//
//  Package.swift
//  KeyboardObserver
//
//  Created by Keith Moon on 28/06/2016.
//  Copyright © 2016 Data Ninjitsu. All rights reserved.
//

import PackageDescription

let package = Package(
    name: "KeyboardObserver",
    targets: [],
    dependencies: [
        .Pac
        
        .Package(url: "https://github.com/apple/example-package-fisheryates.git",
                 majorVersion: 1),
        .Package(url: "https://github.com/apple/example-package-playingcard.git",
                 majorVersion: 1),
        ]
)
