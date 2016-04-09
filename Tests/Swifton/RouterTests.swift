import Swifton
import Inquiline
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
        request = Request(
            method: "GET",
            path: "/testModels/new",
            headers: [("Accept", "text/html")],
            body: ""
        )
    }

    func testResourceIndexRoute() {
        request.path = "/testModels"
        let response = router.respond(request)
        XCTAssertEqual(response.body, "\nSaulius\n\n\n")
    }

    func testNewResourceRoute() {
        let response = router.respond(request)
        XCTAssertEqual(response.body, "header\n\nnew\nfooter\n\n")
    }

    func testShowResourceRoute() {
        request.path = "/testModels/1"
        let response = router.respond(request)
        XCTAssertEqual(response.body, "Saulius\n")
    }

    func testEditResourceRoute() {
        request.path = "/testModels/1/edit"
        let response = router.respond(request)
        XCTAssertEqual(response.body, "Grigaitis\n")
    }

    func testCreateResourcePath() {
        request.path = "/testModels"
        request.method = "POST"
        let response = router.respond(request)
        XCTAssertNil(response.body)
    }

    func testDeleteResourcePath() {
        request.path = "/testModels/1"
        request.method = "POST"
        request.body = "_method=DELETE"
        router.respond(request)
        XCTAssertEqual(TestModel.all.count, 0)
    }

    func testUpdateResourcePath() {
        request.path = "/testModels/1"
        request.method = "POST"
        request.body = "_method=PATCH&name=James"
        router.respond(request)
        let record = TestModel.find(1)!
        XCTAssertEqual(String(record["name"]!), "James")
    }

    func testServeStaticFile() {
        request.path = "/static.txt"
        let staticFile = router.respond(request)
        XCTAssertEqual(staticFile.body, "static\n")
    }

//    TODO: Fix
//    func testServeImage() {
//        request.path = "/image.png"
//        let staticFile = router.respond(request)
//        XCTAssertNotEqual(staticFile.body, "Route Not Found")
//    }

    func testMissingRouteError() {
        request.path = "/nonExisting"
        let response = router.respond(request)
        XCTAssertEqual(response.body, "Route Not Found")
    }

    func testUTF8PostParams() {
        request.path = "/testModels"
        request.method = "POST"
        request.body = "name=Kęstutis&surname=Švitrigaila"
        router.respond(request)
        let record = TestModel.find(2)!
        XCTAssertEqual(String(record.attributes["name"]!), "Kęstutis")
        XCTAssertEqual(String(record.attributes["surname"]!), "Švitrigaila")
    }

}
