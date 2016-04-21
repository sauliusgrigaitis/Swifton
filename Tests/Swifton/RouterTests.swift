import Swifton
import S4
import PathKit
import XCTest

class RouterTests: XCTestCase {

    var router: Router!
    var request: Request!

    static var allTests: [(String, RouterTests -> () throws -> Void)] {
        return [
            ("testResourceIndexRoute", testResourceIndexRoute),
            ("testNewResourceRoute", testNewResourceRoute),
            ("testShowResourceRoute", testShowResourceRoute),
            ("testEditResourceRoute", testEditResourceRoute),
            ("testCreateResourcePath", testCreateResourcePath),
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
        TestModel.create([
            "name": "Saulius",
            "surname": "Grigaitis"
        ])

        router = Router()
        router.resources("testModels", TestModelsController())
    }

    func createRequest(path path: String, method: S4.Method, body: String = "") -> Request {
        return Request(
            method: method,
            uri: URI(path: path),
            headers: ["Accept": "text/html"],
            body: Data(body)
        )
    }

    func testResourceIndexRoute() {
        let request = createRequest(path: "/testModels", method: .get)
        let response = router.respond(request)
        XCTAssertEqual(response.bodyString, "\nSaulius\n\n\n")
    }

    func testNewResourceRoute() {
        let request = createRequest(path: "/testModels/new", method: .get)
        let response = router.respond(request)
        XCTAssertEqual(response.bodyString, "header\n\nnew\nfooter\n\n")
    }

    func testShowResourceRoute() {
        let request = createRequest(path: "/testModels/1", method: .get)
        let response = router.respond(request)
        XCTAssertEqual(response.bodyString, "Saulius\n")
    }

    func testEditResourceRoute() {
        let request = createRequest(path: "/testModels/1/edit", method: .get)
        let response = router.respond(request)
        XCTAssertEqual(response.bodyString, "Grigaitis\n")
    }

    func testCreateResourcePath() {
        let request = createRequest(path: "testModels", method: .post)
        let response = router.respond(request)
        XCTAssertEqual(response.bodyString, "Route Not Found")
    }

    func testDeleteResourcePath() {
        let request = createRequest(path: "/testModels/1", method: .post, body: "_method=DELETE")
        router.respond(request)
        XCTAssertEqual(TestModel.all.count, 0)
    }

    func testUpdateResourcePath() {
        let request = createRequest(path: "/testModels/1", method: .post, body: "_method=PATCH&name=James")
        router.respond(request)
        let record = TestModel.find(1)!
        XCTAssertEqual(String(record["name"]!), "James")
    }

    func testServeStaticFile() {
        let request = createRequest(path: "/static.txt", method: .get)
        let staticFile = router.respond(request)
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
        let response = router.respond(request)
        XCTAssertEqual(response.bodyString, "Route Not Found")
    }

    func testUTF8PostParams() {
        let request = createRequest(path: "/testModels", method: .post, body: "name=Kęstutis&surname=Švitrigaila")
        router.respond(request)
        let record = TestModel.find(2)!
        XCTAssertEqual(String(record.attributes["name"]!), "Kęstutis")
        XCTAssertEqual(String(record.attributes["surname"]!), "Švitrigaila")
    }

}
