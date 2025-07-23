//
//  Package.swift
//  SHMR_Finance_App
//
//  Created by Chernokoz on 23.07.2025.
//

import Foundation
import PackageDescription

let package = Package(
    name: "SHMR_Finance_App",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "SHMR_Finance_App",
            targets: ["SHMR_Finance_App"]),
    ],
    dependencies: [
        .package(url: "https://github.com/airbnb/lottie-ios.git", from: "4.0.0")
    ],
    targets: [
        .target(
            name: "SHMR_Finance_App",
            dependencies: [
                .product(name: "Lottie", package: "lottie-ios")
            ],
            resources: [
                // Добавь сюда свои ресурсы, если нужно
                // .process("SHMR_Finance_App/Assets.xcassets"),
                .process("SHMR_Finance_App/Lottie/upload.json")
            ]
        )
    ]
)
