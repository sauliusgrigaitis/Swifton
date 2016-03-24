import XCTest
import Swifton
import PathKit

class SwiftonTest: XCTestCase {

    var allTests: [(String, () throws -> Void)] {
        return []
    }

    #if os(Linux)
        func setUp() {
            doSetUp()
        }
    #else
        override func setUp() {
            doSetUp()
        }
    #endif

    func doSetUp() {
        SwiftonConfig.viewsDirectory = (Path(#file).parent() + "Fixtures/Views").description
        SwiftonConfig.publicDirectory = (Path(#file).parent() + "Fixtures").description
    }

}