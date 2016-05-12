import XCTest

@testable import SwiftonTestSuite

XCTMain([
    testCase(MemoryModelTests.allTests),
    testCase(ControllerTests.allTests),
    testCase(FilterTests.allTests),
    testCase(RouterTests.allTests)
])
