import Quick
import Nimble
import Swifton
import Inquiline

class ControllerSpec: QuickSpec {
    override func spec() {
        describe("Controller") {
            let controller = TestModelsController()
            var request:Request!
            var postRequest:Request!
            var record:TestModel!
            beforeEach {
                SwiftonConfig.viewsDirectory = "Sources/Spec/Fixtures/Views" 
                TestModel.reset()
                record = TestModel.create([
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

            it("Renders HTML collection") {
                TestModel.create(["name": "James", "surname": "Bond"])
                let rendered = controller["index"](request: request)
                expect(rendered.body).to(equal("\nSaulius\n\nJames\n\n\n"))
            }

            it("Renders JSON collection") {
                TestModel.create(["name": "James", "surname": "Bond"])
                request.headers = [("Accept", "application/json")]
                let rendered = controller["index"](request: request)
                let firstModel = "{\"name\": \"Saulius\", \"surname\": \"Grigaitis\", \"id\": \"1\"}"
                let secondModel = "{\"name\": \"James\", \"surname\": \"Bond\", \"id\": \"2\"}"
                expect(rendered.body).to(equal("{\"testModels\": [\(firstModel), \(secondModel)]}"))
            }

            it("Renders HTML single model with UTF8 string") {
                TestModel.create(["name": "ąčęėį"])
                request.params = ["id": "2"]
                let rendered = controller["show"](request: request)
                expect(rendered.body).to(equal("ąčęėį\n"))
            }

            it("Renders HTML single model") {
                request.params = ["id": "1"]
                let rendered = controller["show"](request: request)
                expect(rendered.body).to(equal("Saulius\n"))
            }

            it("Renders static HTML") {
                let rendered = controller["new"](request: request)
                expect(rendered.body).to(equal("new\n"))
            }

            it("Parses POST request and uses params to create record") {
                controller["create"](request: postRequest)
                let record = TestModel.find(2)!
                expect(String(record["name"]!)).to(equal("James"))
                expect(String(record["surname"]!)).to(equal("Bond"))
            }

            it("redirects using 'redirectTo' method") {
                postRequest.params["id"] = "1"
                let redirect = controller["update"](request: postRequest)
                expect(redirect["Location"]).to(equal("/testModels/1"))
            }
        }
    }
}
