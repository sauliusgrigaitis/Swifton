import XCTest

@testable import SwiftonTestSuite

XCTMain([
    testCase(MemoryModelTests.allTests),
    testCase(ControllerTests.allTests),
    testCase(RouterTests.allTests)
])
