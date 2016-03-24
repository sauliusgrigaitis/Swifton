import PackageDescription

let package = Package(
    name: "Swifton",
    dependencies: [
        .Package(url: "https://github.com/necolt/Stencil.git", versions: Version(0,5,3)..<Version(1,0,0)),
        .Package(url: "https://github.com/necolt/Inquiline.git", versions: Version(0,2,2)..<Version(1,0,0)),
        .Package(url: "https://github.com/necolt/URITemplate.swift.git", versions: Version(1,3,1)..<Version(2,0,0))
    ]
)
