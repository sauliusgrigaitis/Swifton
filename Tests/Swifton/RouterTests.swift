@testable import Swifton
import S4
import PathKit
import XCTest

class RouterTests: XCTestCase {

    var router: Router!
    var request: Request!

    static var allTests: [(String, (RouterTests) -> () throws -> Void)] {
        return [
            ("testResourceIndexRoute", testResourceIndexRoute),
            ("testNewResourceRoute", testNewResourceRoute),
            ("testShowResourceRoute", testShowResourceRoute),
            ("testEditResourceRoute", testEditResourceRoute),
            ("testCreateResourcePath", testCreateResourcePath),
            ("testDeleteResourcePath", testDeleteResourcePath),
            ("testUpdateResourcePath", testUpdateResourcePath),
            ("testServeStaticFile", testServeStaticFile),
            ("testMissingRouteError", testMissingRouteError),
            ("testUTF8PostParams", testUTF8PostParams)
        ]
    }

    override func setUp() {
        SwiftonConfig.viewsDirectory = (Path(#file).parent() + "Fixtures/Views").description
        SwiftonConfig.publicDirectory = (Path(#file).parent() + "Fixtures").description

        TestModel.reset()
        TestModel.create(["name": "Saulius", "surname": "Grigaitis"])

        router = Router.create { route in
            route.resources("testModels", controller: TestModelsController())
        }
    }

    func createRequest(path: String, method: S4.Method, body: String = "") -> Request {
        return Request(
            method: method,
            uri: URI(path: path),
            headers: ["Accept": "text/html,test"],
            body: Data(body)
        )
    }

    func testResourceIndexRoute() {
        let request = createRequest(path: "/testModels", method: .get)
        let response = try! router.respond(to: request)
        XCTAssertEqual(response.bodyString, "\nSaulius\n\n\n")
    }

    func testNewResourceRoute() {
        let request = createRequest(path: "/testModels/new", method: .get)
        let response = try! router.respond(to: request)
        XCTAssertEqual(response.bodyString, "header\n\nnew\nfooter\n\n")
    }

    func testShowResourceRoute() {
        let request = createRequest(path: "/testModels/1", method: .get)
        let response = try! router.respond(to: request)
        XCTAssertEqual(response.bodyString, "Saulius\n")
    }

    func testEditResourceRoute() {
        let request = createRequest(path: "/testModels/1/edit", method: .get)
        let response = try! router.respond(to: request)
        XCTAssertEqual(response.bodyString, "Grigaitis\n")
    }

    func testCreateResourcePath() {
        let request = createRequest(path: "testModels", method: .post)
        let response = try! router.respond(to: request)
        XCTAssertEqual(response.statusCode, 302)
        XCTAssertEqual(response.bodyString, "")
    }

    func testDeleteResourcePath() {
        let request = createRequest(path: "/testModels/1", method: .post, body: "_method=DELETE")
        try! router.respond(to: request)
        XCTAssertEqual(TestModel.all.count, 0)
    }

    func testUpdateResourcePath() {
        let request = createRequest(path: "/testModels/1", method: .post, body: "_method=PATCH&name=James")
        try! router.respond(to: request)
        let record = TestModel.find(1)!
        XCTAssertEqual(String(record["name"]!), "James")
    }

    func testServeStaticFile() {
        let request = createRequest(path: "/static.txt", method: .get)
        let staticFile = try! router.respond(to: request)
        XCTAssertEqual(staticFile.bodyString, "static\n")
    }

//    TODO: Fix
//    func testServeImage() {
//        request.path = "/image.png"
//        let staticFile = router.respond(request)
//        XCTAssertNotEqual(staticFile.body, "Route Not Found")
//    }

    func testMissingRouteError() {
        let request = createRequest(path: "/nonExisting", method: .get)
        let response = try! router.respond(to: request)
        XCTAssertEqual(response.bodyString, "Route Not Found")
    }

    func testUTF8PostParams() {
        let request = createRequest(path: "/testModels", method: .post, body: "name=Kęstutis&surname=Švitrigaila")
        try! router.respond(to: request)
        let record = TestModel.find(2)!
        XCTAssertEqual(String(record.attributes["name"]!), "Kęstutis")
        XCTAssertEqual(String(record.attributes["surname"]!), "Švitrigaila")
    }

}
