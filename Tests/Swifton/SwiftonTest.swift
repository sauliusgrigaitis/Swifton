import XCTest
import Swifton
import PathKit

class SwiftonTest: XCTestCase {

    var allTests: [(String, () throws -> Void)] {
        return []
    }

    override func setUp() {
        doSetUp()
    }

    func doSetUp() {
        SwiftonConfig.viewsDirectory = (Path(#file).parent() + "Fixtures/Views").description
        SwiftonConfig.publicDirectory = (Path(#file).parent() + "Fixtures").description
    }

}
