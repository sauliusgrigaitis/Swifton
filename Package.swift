import PackageDescription

let package = Package(
    name: "Swifton",
    dependencies: [
        .Package(url: "https://github.com/necolt/Stencil.git", versions: Version(0,5,6)..<Version(1,0,0)),
        .Package(url: "https://github.com/Zewo/String.git", majorVersion: 0, minor: 7),
        .Package(url: "https://github.com/open-swift/S4.git", majorVersion: 0, minor: 6),
        .Package(url: "https://github.com/Zewo/Router.git", majorVersion: 0, minor: 6)
    ]
)
