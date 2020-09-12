// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "CITreeView",
    products: [
        .library(name: "CITreeView", targets: ["CITreeView"])
    ],
    targets: [
        .target(name: "CITreeView", path: "CITreeViewClasses")
    ]
)
