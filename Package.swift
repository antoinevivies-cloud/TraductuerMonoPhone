// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "StereoDashVoice",
    platforms: [.iOS(.v17)],
    products: [.executable(name: "StereoDashVoice", targets: ["StereoDashVoice"])],
    targets: [.executableTarget(name: "StereoDashVoice", path: "Sources")]
)
