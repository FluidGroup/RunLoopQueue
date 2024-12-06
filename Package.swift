// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "WithPrerender",
  platforms: [
    .iOS(.v13),
    .macOS(.v10_15),
    .tvOS(.v13),
    .watchOS(.v10),
    .visionOS(.v1)    
  ],
  products: [
    // Products define the executables and libraries a package produces, making them visible to other packages.
    .library(
      name: "WithPrerender",
      targets: ["WithPrerender"]
    ),
    .library(
      name: "CATransactionQueue",
      targets: ["CATransactionQueue"]
    ),
  ],
  targets: [
    // Targets are the basic building blocks of a package, defining a module or a test suite.
    // Targets can depend on other targets in this package and products from dependencies.
    .target(name: "CATransactionQueue"),
    .target(
      name: "WithPrerender",
      dependencies: ["CATransactionQueue"]
    ),
    .testTarget(
      name: "WithPrerenderTests",
      dependencies: ["WithPrerender"]
    ),
  ],
  swiftLanguageModes: [.v6]
)
