import S4

public class Controller {

    public typealias Action = Respond
    public typealias Filter = (request: Request) -> Response?

    var actions = [String: Action]()
    var filters = [String: Filter]()
    var beforeFilters = FilterCollection()
    var afterFilters = FilterCollection()

    public let next: Response? = nil

    public init() { controller() }

    public func controller() {}

    public func action(_ name: String, body: Action) {
        actions[name] = body
    }

    public func filter(_ name: String, body: Filter) {
        filters[name] = body
    }

    public subscript(actionName: String) -> Action {
        get {
            return { request in
                guard let action = self.actions[actionName] else {
                    return Response(status: .notFound, body: "Action Not Found")
                }

                if let filterResponse = self.run(filters: self.beforeFilters, forAction: actionName, request: request) {
                    return filterResponse
                }

                let response = try! action(to: request)

                if let filterResponse = self.run(filters: self.afterFilters, forAction: actionName, request: request) {
                    return filterResponse
                }

                return response
            }
        }

        set(newValue) {
            actions[actionName] = newValue
        }
    }

    public func beforeAction(_ filter: String) {
        beforeFilters.set(filter: filter)
    }

    public func beforeAction(_ filter: String, only actions: String...) {
        beforeFilters.set(filter: filter, onlyForActions: actions)
    }

    public func beforeAction(_ filter: String, except actions: String...) {
        beforeFilters.set(filter: filter, exceptForActions: actions)
    }

    public func afterAction(_ filter: String) {
        afterFilters.set(filter: filter)
    }

    public func afterAction(_ filter: String, only actions: String...) {
        afterFilters.set(filter: filter, onlyForActions: actions)
    }

    public func afterAction(_ filter: String, except actions: String...) {
        afterFilters.set(filter: filter, exceptForActions: actions)
    }

    private func run(filters: FilterCollection, forAction action: String, request: Request) -> Response? {
        for filterName in filters.forAction(action) {
            guard let filter = self.filters[filterName] else {
                return Response(status: .internalServerError, body: "Undefined filter: \(filterName)")
            }

            if let response = filter(request: request) {
                return response
            }
        }

        return nil
    }

}

public func render(_ template: String) -> Response {
    let body = StencilView(template).render()
    return Response(status: .ok, contentType: .HTML, body: body)
}

public func render(_ template: String, _ object: HTMLRenderable?) -> Response {
    var body: String
    if let obj = object {
        body = StencilView(template, obj.renderableAttributes()).render()
    } else {
        body = StencilView(template).render()
    }
    return Response(status: .ok, contentType: .HTML, body: body)
}

public func render(_ template: String, _ context: [String: Any]) -> Response {
    let body = StencilView(template, context).render()
    return Response(status: .ok, contentType: .HTML, body: body)
}

public func renderJSON(object: JSONRenderable?) -> Response {
    var body: String
    if let obj = object {
        body = JSONView(obj.renderableJSONAttributes()).render()
    } else {
        body = "null"
    }
    return Response(status: .ok, contentType: .JSON, body: body)
}

public func renderJSON(_ context: [String: Any]? = nil) -> Response {
    let body = JSONView(context).render()
    return Response(status: .ok, contentType: .JSON, body: body)
}

public func redirectTo(_ path: String) -> Response {
    return Response(status: .found, headers: ["Location": Header(path)])
}

public func respondTo(_ request: Request, _ responders: [String: () -> Response]) -> Response {
    let accepts = request.headers["Accept"].values.first?.split(separator: ",") ?? []
    for (accept, response) in responders {
        if accepts.contains(accept.mimeType()) {
            return response()
        }
    }
    return Response(status: .notAcceptable)
}
