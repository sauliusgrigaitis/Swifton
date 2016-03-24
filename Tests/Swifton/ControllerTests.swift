import XCTest
import Swifton
import Inquiline

class ControllerTests: SwiftonTest {

    let controller = TestModelsController()
    var request: Request!
    var postRequest: Request!

    override var allTests: [(String, () throws -> Void)] {
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

    override func doSetUp() {
        super.doSetUp()

        Controller.applicationController = TestApplicationController()
        TestModel.reset()
        TestModel.create([
            "name": "Saulius",
            "surname": "Grigaitis"
        ])
        request = Request(
            method: "GET",
            path: "/",
            headers: [("Accept", "text/html")],
            body: ""
        )
        postRequest = Request(
            method: "POST",
            path: "/",
            headers: [("Accept", "text/html")],
            body: ""
        )
        postRequest.params = ["name": "James", "surname": "Bond"]
    }

    func testRenderHtmlCollection() {
        TestModel.create(["name": "James", "surname": "Bond"])
        let rendered = controller["index"](request: request)
        XCTAssertEqual(rendered.body, "\nSaulius\n\nJames\n\n\n")
    }

    func testRenderJsonCollection() {
        TestModel.create(["name": "James", "surname": "Bond"])
        request.headers = [("Accept", "application/json")]
        let rendered = controller["index"](request: request)

        let recordsJson: [String] = TestModel.all.map { record in
            let attributes = record.attributes.map { "\"\($0)\": \"\($1)\"" }
            return "{\(attributes.joinWithSeparator(", "))}"
        }

        XCTAssertEqual(rendered.body, "{\"testModels\": [\(recordsJson.joinWithSeparator(", "))]}")
    }

    func testRenderHtmlSingleModel() {
        request.params = ["id": "1"]
        let rendered = controller["show"](request: request)
        XCTAssertEqual(rendered.body, "Saulius\n")
    }

    func testRenderHtmlSingleModelWithUTF8() {
        TestModel.create(["name": "ąčęėį"])
        request.params = ["id": "2"]
        let rendered = controller["show"](request: request)
        XCTAssertEqual(rendered.body, "ąčęėį\n")
    }

    func testRenderHtmlIncludesHeaderAndFooter() {
        let rendered = controller["new"](request: request)
        XCTAssertEqual(rendered.body, "header\n\nnew\nfooter\n\n")
    }

    func testPostRequestToCreateRecord() {
        controller["create"](request: postRequest)
        let record = TestModel.find(2)!
        XCTAssertEqual(String(record["name"]!), "James")
        XCTAssertEqual(String(record["surname"]!), "Bond")
    }

    func testRedirect() {
        postRequest.params["id"] = "1"
        let redirect = controller["update"](request: postRequest)
        XCTAssertEqual(redirect["Location"], "/testModels/1")
    }

}
