import Quick
import Nimble
import Swifton
import Inquiline

class RouterSpec: QuickSpec {
    override func spec() {
        describe("Router") {
            var router:Router!
            var request:Request!
            beforeEach {
                SwiftonConfig.viewsDirectory = "Sources/Spec/Fixtures/Views" 
                SwiftonConfig.publicDirectory = "Sources/Spec/Fixtures" 

                TestModel.reset()
                TestModel.create([
                    "name": "Saulius", 
                    "surname": "Grigaitis"
                ])
 
                router = Router()
                router.resources("testModels", TestModelsController())
                request = Request(
                    method: "GET", 
                    path: "/testModels/new", 
                    headers: [("Accept", "text/html")], 
                    body: ""
                )
            }
            describe("Resources") {
                it("creates get '<resources>/new' route") {
                    let response = router.respond(request)
                    expect(response.body).to(equal("new\n"))
                }

                it("creates get '<resources>/{id}' route") {
                    request.path = "/testModels/1"
                    let response = router.respond(request)
                    expect(response.body).to(equal("Saulius\n"))
                }

                it("creates get '<resources>/{id}/edit' route") {
                    request.path = "/testModels/1/edit"
                    let response = router.respond(request)
                    expect(response.body).to(equal("Grigaitis\n"))
                }

                it("creates get '<resources>' route") {
                    request.path = "/testModels"
                    let response = router.respond(request)
                    expect(response.body).to(equal("\nSaulius\n\n\n"))
                }

                it("creates post '<resources>' route") {
                    request.path = "/testModels"
                    request.method = "POST"
                    let response = router.respond(request)
                    expect(response.body).to(beNil())
                }

                it("creates delete '<resources>/{id}' route") {
                    request.path = "/testModels/1"
                    request.method = "POST"
                    request.body = "_method=DELETE"
                    router.respond(request)
                    expect(TestModel.all.count).to(equal(0))
                }

                it("creates patch '<resources>/{id}' route") {
                    request.path = "/testModels/1"
                    request.method = "POST"
                    request.body = "_method=PATCH"
                    router.respond(request)
                }
            }

            describe("Static files") {
                it("serves static file if action is not found") {
                    request.path = "/static.txt"
                    let staticFile = router.respond(request)
                    expect(staticFile.body).to(equal("static\n"))
                }

                it("chooses the appropriate mimeType for a plaintext file") {
                    request.path = "/static.txt"
                    let staticFile = route.repond(request)
                    expect(staticFile.contentType).to(equal("text/plain; charset=utf8"))
                }

                it("chooses the appropriate mimeType for a javascript file") {
                    request.path = "/static.js"
                    let staticFile = route.repond(request)
                    expect(staticFile.contentType).to(equal("application/javascript; charset=utf8"))
                }


            }

            describe("Errors") {
                it("returns 'Route not Found' if no action and no static file is found") {
                    request.path = "/nonExisting"
                    let response = router.respond(request)
                    expect(response.body).to(equal("Route Not Found"))
                }
            }

            describe("Parameters parser") {
                it("supports UTF8 POST params") {
                    request.path = "/testModels"
                    request.method = "POST"
                    request.body = "name=Kęstutis&surname=Švitrigaila"
                    router.respond(request)
                    let record = TestModel.find(2)!
                    expect(String(record.attributes["name"]!)).to(equal("Kęstutis"))
                    expect(String(record.attributes["surname"]!)).to(equal("Švitrigaila"))
                }
            }
        }
    }
}
