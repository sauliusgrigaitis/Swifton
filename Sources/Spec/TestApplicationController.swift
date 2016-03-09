import Swifton

class TestApplicationController: Controller {
    override func controller() {
        filter("reset") { request in
            print("reset")    
            return self.next
        }
    }
}
