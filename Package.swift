// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "Attntiv",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "Attntiv",
            targets: ["Attntiv"]),
    ],
    dependencies: [
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", from: "10.0.0"),
        .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.0.0"),
        .package(url: "https://github.com/onevcat/Kingfisher.git", from: "7.0.0"),
        .package(url: "https://github.com/SwiftyJSON/SwiftyJSON.git", from: "5.0.0")
    ],
    targets: [
        .target(
            name: "Attntiv",
            dependencies: [
                .product(name: "FirebaseAuth", package: "firebase-ios-sdk"),
                .product(name: "FirebaseFirestore", package: "firebase-ios-sdk"),
                .product(name: "FirebaseStorage", package: "firebase-ios-sdk"),
                .product(name: "FirebaseMessaging", package: "firebase-ios-sdk"),
                .product(name: "FirebaseAnalytics", package: "firebase-ios-sdk"),
                "Alamofire",
                "Kingfisher",
                "SwiftyJSON"
            ],
            path: "Sources"
        ),
        .testTarget(
            name: "AttntivTests",
            dependencies: ["Attntiv"],
            path: "Tests"
        )
    ]
) 