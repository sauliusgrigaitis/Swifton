import Swifton

class TestModelsController: TestApplicationController { 
    var testModel: TestModel?    
    override init() { super.init()

    beforeAction("setTestModel", ["only": ["show", "edit", "update", "destroy"]])

    action("index") { request in
        let testModels = ["testModels": TestModel.allAttributes()]
        return self.respondTo(request, [
            "html": { self.render("TestModels/Index", testModels) },
            "json": { self.renderJSON(testModels) }
        ])
    }

    action("show") { request in
        return self.render("TestModels/Show", self.testModel)
    }

    action("new") { request in
        return self.render("TestModels/New")
    }

    action("edit") { request in
        return self.render("TestModels/Edit", self.testModel)
    } 
    action("create") { request in
        TestModel.create(request.params)
        return self.redirectTo("/testModels")
    }

    action("update") { request in
        self.testModel!.update(request.params)
        return self.redirectTo("/testModels/\(self.testModel!.id)")
    }

    action("destroy") { request in
        TestModel.destroy(self.testModel)
        return self.redirectTo("/testModels")
    }

    filter("setTestModel") { request in
        guard let t = TestModel.find(request.params["id"]) else { return self.redirectTo("/testModels") } 
        self.testModel = t as? TestModel
        return self.next
    }
}}
