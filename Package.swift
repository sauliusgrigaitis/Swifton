import PackageDescription

let package = Package(
    name: "Swifton",
    dependencies: [
        .Package(url: "https://github.com/necolt/Stencil.git", versions: Version(0,5,4)..<Version(1,0,0)),
        .Package(url: "https://github.com/Zewo/String.git", versions: Version(0,1,0)..<Version(1,0,0)),
        .Package(url: "https://github.com/necolt/Inquiline.git", versions: Version(0,2,3)..<Version(1,0,0)),
        .Package(url: "https://github.com/necolt/URITemplate.swift.git", versions: Version(1,3,2)..<Version(2,0,0))
    ]
)
