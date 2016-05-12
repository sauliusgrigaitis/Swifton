@testable import Swifton
import XCTest

class FiltersBaseController: Controller {

    var calledFilters = [String]()

    func renderFilters() -> Response {
        return Response(body: self.calledFilters.joined(separator: " "))
    }

    override func controller() {

    beforeAction("beforeAllBase")
    beforeAction("beforeAll")

    filter("beforeAllBase") { request in
        self.calledFilters.append("beforeAllBase")
        return self.next
    }

    filter("beforeAll") { request in
        self.calledFilters.append("beforeAllToBeOverriden")
        return self.next
    }

    action("base") { request in
        return self.renderFilters()
    }

}}

class FiltersController: FiltersBaseController {

    override func controller() {
    super.controller()

    beforeAction("undefined", only: "error")

    beforeAction("beforeOnlyA&C", only: "a", "c")
    beforeAction("beforeExceptA")
    beforeAction("beforeExceptA", except: "a")

    afterAction("afterOnlyB", only: "b")
    afterAction("afterExceptB&C", except: "b", "c")
    afterAction("afterAll")

    action("a") { request in
        return Response()
    }

    action("b") { request in
        return Response()
    }

    action("c") { request in
        return Response()
    }
    
    action("error") { request in
        return Response()
    }

    filter("beforeAll") { request in
        self.calledFilters.append("beforeAll")
        return self.next
    }

    filter("beforeOnlyA&C") { request in
        self.calledFilters.append("beforeOnlyA&C")
        return self.next
    }

    filter("beforeExceptA") { request in
        self.calledFilters.append("beforeExceptA")
        return self.next
    }

    filter("afterOnlyB") { request in
        self.calledFilters.append("afterOnlyB")
        return self.next
    }

    filter("afterExceptB&C") { request in
        self.calledFilters.append("afterExceptB&C")
        return self.next
    }

    filter("afterAll") { request in
        self.calledFilters.append("afterAll")
        return self.renderFilters()
    }

}}

class FilterTests: XCTestCase {

    static var allTests: [(String, (FilterTests) -> () throws -> Void)] {
        return [
            ("testBeforeFilters", testBeforeFilters),
            ("testBeforeOnlyFilters", testBeforeOnlyFilters),
            ("testBeforeExceptFilters", testBeforeExceptFilters),
            ("testAfterFilters", testAfterFilters),
            ("testAfterOnlyFilters", testAfterOnlyFilters),
            ("testAfterExceptFilters", testAfterExceptFilters),
            ("testFiltersOrder", testFiltersOrder),
            ("testInheritedFilters", testInheritedFilters),
            ("testOverridingInheritedFilters", testOverridingInheritedFilters),
            ("testUndefinedFilters", testUndefinedFilters)
        ]
    }

    var baseFilters: [String]!
    var aFilters: [String]!
    var bFilters: [String]!
    var cFilters: [String]!

    func filters(controller: Controller, forAction action: String) -> [String] {
        return try! controller[action](to: Request()).bodyString!.split(byString: " ")
    }

    override func setUp() {
        baseFilters = filters(controller: FiltersBaseController(), forAction: "base")
        aFilters = filters(controller: FiltersController(), forAction: "a")
        bFilters = filters(controller: FiltersController(), forAction: "b")
        cFilters = filters(controller: FiltersController(), forAction: "c")
    }

    func testBeforeFilters() {
        XCTAssert(aFilters.contains("beforeAll"))
        XCTAssert(bFilters.contains("beforeAll"))
        XCTAssert(cFilters.contains("beforeAll"))
    }

    func testBeforeOnlyFilters() {
        XCTAssert(aFilters.contains("beforeOnlyA&C"))
        XCTAssertFalse(bFilters.contains("beforeOnlyA&C"))
        XCTAssert(cFilters.contains("beforeOnlyA&C"))
    }

    func testBeforeExceptFilters() {
        XCTAssertFalse(aFilters.contains("beforeExceptA"))
        XCTAssert(bFilters.contains("beforeExceptA"))
        XCTAssert(cFilters.contains("beforeExceptA"))
    }

    func testAfterFilters() {
        XCTAssert(aFilters.contains("afterAll"))
        XCTAssert(bFilters.contains("afterAll"))
        XCTAssert(cFilters.contains("afterAll"))
    }

    func testAfterOnlyFilters() {
        XCTAssertFalse(aFilters.contains("afterOnlyB"))
        XCTAssert(bFilters.contains("afterOnlyB"))
        XCTAssertFalse(cFilters.contains("afterOnlyB"))
    }

    func testAfterExceptFilters() {
        XCTAssert(aFilters.contains("afterExceptB&C"))
        XCTAssertFalse(bFilters.contains("afterExceptB&C"))
        XCTAssertFalse(cFilters.contains("afterExceptB&C"))
    }

    func testFiltersOrder() {
        XCTAssertEqual(aFilters, ["beforeAllBase", "beforeAll", "beforeOnlyA&C", "afterExceptB&C", "afterAll"])
    }

    func testInheritedFilters() {
        XCTAssert(baseFilters.contains("beforeAllBase"))
        XCTAssert(aFilters.contains("beforeAllBase"))
    }

    func testOverridingInheritedFilters() {
        XCTAssert(baseFilters.contains("beforeAllToBeOverriden"))
        XCTAssertFalse(aFilters.contains("beforeAllToBeOverriden"))
    }

    func testUndefinedFilters() {
        let errorReponse = try! FiltersController()["error"](to: Request()).bodyString!
        XCTAssertEqual(errorReponse, "Undefined filter: undefined")
    }

}
