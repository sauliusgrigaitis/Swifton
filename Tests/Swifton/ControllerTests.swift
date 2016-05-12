@testable import Swifton
import S4
import PathKit
import XCTest

class ControllerTests: XCTestCase {

    let controller = TestModelsController()
    var request: Request!
    var postRequest: Request!

    static var allTests: [(String, (ControllerTests) -> () throws -> Void)] {
        return [
            ("testRenderHtmlCollection", testRenderHtmlCollection),
            ("testRenderJsonCollection", testRenderJsonCollection),
            ("testRenderHtmlSingleModel", testRenderHtmlSingleModel),
            ("testRenderHtmlSingleModelWithUTF8", testRenderHtmlSingleModelWithUTF8),
            ("testRenderHtmlIncludesHeaderAndFooter", testRenderHtmlIncludesHeaderAndFooter),
            ("testPostRequestToCreateRecord", testPostRequestToCreateRecord),
            ("testRedirect", testRedirect)
        ]
    }

    override func setUp() {
        SwiftonConfig.viewsDirectory = (Path(#file).parent() + "Fixtures/Views").description
        SwiftonConfig.publicDirectory = (Path(#file).parent() + "Fixtures").description

        TestModel.reset()
        TestModel.create(["name": "Saulius", "surname": "Grigaitis"])
        request = createRequest()

        postRequest = Request(
            method: .post,
            uri: URI(path: "/"),
            headers: ["Accept": "text/html"]
        )
        postRequest.params = ["name": "James", "surname": "Bond"]
    }

    private func createRequest(path: String = "/", method: S4.Method = .get,
        headers: Headers = [:], body: String = "") -> Request {

        var headers = headers
        if headers["Accept"].values.isEmpty {
            headers["Accept"] = "text/html"
        }

        return Request(
            method: method,
            uri: URI(path: path),
            headers: headers,
            body: Data(body)
        )
    }

    func testRenderHtmlCollection() {
        TestModel.create(["name": "James", "surname": "Bond"])
        let rendered = try! controller["index"](to: request)
        XCTAssertEqual(rendered.bodyString, "\nSaulius\n\nJames\n\n\n")
    }

    func testRenderJsonCollection() {
        TestModel.create(["name": "James", "surname": "Bond"])
        let request = createRequest(headers: ["Accept": "application/json"])
        let rendered = try! controller["index"](to: request)

        let recordsJson: [String] = TestModel.all.map { record in
            let attributes = record.attributes.map { "\"\($0)\": \"\($1)\"" }
            return "{\(attributes.joined(separator: ", "))}"
        }

        XCTAssertEqual(rendered.bodyString, "{\"testModels\": [\(recordsJson.joined(separator: ", "))]}")
    }

    func testRenderHtmlSingleModel() {
        request.params = ["id": "1"]
        let rendered = try! controller["show"](to: request)
        XCTAssertEqual(rendered.bodyString, "Saulius\n")
    }

    func testRenderHtmlSingleModelWithUTF8() {
        TestModel.create(["name": "ąčęėį"])
        request.params = ["id": "2"]
        let rendered = try! controller["show"](to: request)
        XCTAssertEqual(rendered.bodyString, "ąčęėį\n")
    }

    func testRenderHtmlIncludesHeaderAndFooter() {
        let rendered = try! controller["new"](to: request)
        XCTAssertEqual(rendered.bodyString, "header\n\nnew\nfooter\n\n")
    }

    func testPostRequestToCreateRecord() {
        try! controller["create"](to: postRequest)
        let record = TestModel.find(2)!
        XCTAssertEqual(String(record["name"]!), "James")
        XCTAssertEqual(String(record["surname"]!), "Bond")
    }

    func testRedirect() {
        postRequest.params["id"] = "1"
        let redirect = try! controller["update"](to: postRequest)
        XCTAssertEqual(redirect.headers["Location"], "/testModels/1")
    }

}
