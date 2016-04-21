import PackageDescription

let package = Package(
    name: "Swifton",
    dependencies: [
        .Package(url: "https://github.com/necolt/Stencil.git", versions: Version(0,5,4)..<Version(1,0,0)),
        .Package(url: "https://github.com/Zewo/String.git", majorVersion: 0, minor: 4),
        .Package(url: "https://github.com/open-swift/S4.git", majorVersion: 0, minor: 3),
        .Package(url: "https://github.com/necolt/URITemplate.swift.git", versions: Version(1,3,2)..<Version(2,0,0))
    ]
)
