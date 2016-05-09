@testable import Swifton

class TestApplicationController: Controller {
    override func controller() {
        filter("reset") { request in
            return self.next
        }
    }
}
