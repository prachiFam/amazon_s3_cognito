// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "amazon_s3_cognito",
    platforms: [
        .iOS("13.0")
    ],
    products: [
        .library(name: "amazon-s3-cognito", targets: ["amazon_s3_cognito"])
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework"),
        .package(url: "https://github.com/aws-amplify/aws-sdk-ios-spm", from: "2.41.0")
    ],
    targets: [
        .target(
            name: "amazon_s3_cognito",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework"),
                .product(name: "AWSS3", package: "aws-sdk-ios-spm"),
                .product(name: "AWSCore", package: "aws-sdk-ios-spm")
            ]
        )
    ]
)
