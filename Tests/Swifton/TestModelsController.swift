@testable import Swifton

class TestModelsController: TestApplicationController {
    var testModel: TestModel?

    override func controller() {
    super.controller()

    beforeAction("setTestModel", only: "show", "edit", "update", "destroy")
    beforeAction("reset", only: "show")
    beforeAction("crash", except: "index", "show", "new", "edit", "create", "update", "destroy")

    action("index") { request in
        let testModels = ["testModels": TestModel.allAttributes()]
        return respondTo(request, [
            "html": { render("TestModels/Index", testModels) },
            "json": { renderJSON(testModels) }
        ])
    }

    action("show") { request in
        return render("TestModels/Show", self.testModel)
    }

    action("new") { request in
        return render("TestModels/New")
    }

    action("edit") { request in
        return render("TestModels/Edit", self.testModel)
    }

    action("create") { request in
        TestModel.create(request.params)
        return redirectTo("/testModels")
    }

    action("update") { request in
        self.testModel!.update(request.params)
        return redirectTo("/testModels/\(self.testModel!.id)")
    }

    action("destroy") { request in
        TestModel.destroy(self.testModel)
        return redirectTo("/testModels")
    }

    filter("setTestModel") { request in
        guard let t = TestModel.find(request.params["id"]) else {
            return redirectTo("/testModels")
        }

        self.testModel = t as? TestModel
        return self.next
    }

    filter("crash") { request in
        let crash: String? = nil
        let _ = crash!
        return self.next
    }
}}
