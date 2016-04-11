import S4

public class Controller {
    public typealias Parameters = [String: String]
    public typealias Action = (request: Request) -> Response
    public typealias Filter = (request: Request) -> Response?
    public typealias FilterCollection = [String: FilterOptions]
    public typealias FilterOptions = [String: [String]]?

    public static var applicationController = Controller()
    var actions = [String: Action]()
    var filters = [String: Filter]()
    var beforeFilters = FilterCollection()
    var afterFilters = FilterCollection()
    public let next: Response? = nil

    public init() { controller() }

    public func controller() {}

    public func action(name: String, body: Action) {
        actions[name] = body
    }

    public func filter(name: String, body: Filter) {
        filters[name] = body
    }

    public subscript(actionName: String) -> Action {
        get {
            return { (request) in
                guard let action = self.actions[actionName] else {
                    return Response(status: .notFound, contentType: .Plain, body: "Action Not Found")
                }

                if let filterResponse = self.runFilters(request, actionName, self.beforeFilters) {
                    return filterResponse
                }

                let response = action(request: request)

                if let filterResponse = self.runFilters(request, actionName, self.afterFilters) {
                    return filterResponse
                }

                return response
            }
        }

        set(newValue) {
            actions[actionName] = newValue
        }
    }

    func runFilters(request: Request, _ actionName: String, _ filterCollection: FilterCollection) -> Response? {
        for (filter, options) in filterCollection {
            // prefer filter in child controller
            if let selectedFilter = self.filters[filter] {
                if let response = runFilter(selectedFilter, actionName, request, options) {
                    return response
                }
            } else if let selectedFilter = Controller.applicationController.filters[filter] {
                if let response = selectedFilter(request: request) {
                    return response
                }
            }
        }
        return nil
    }

    func runFilter(filter: Filter, _ actionName: String, _ request: Request, _ options: FilterOptions) -> Response? {
        // if "only" option is used then check if action is in the list
        if let opts = options {
            if let skip = opts["skip"] {
                if skip.contains(actionName) {
                    return nil
                } else {
                    if let response = filter(request: request) {
                        return response
                    }
                }
            }
            if let only = opts["only"] {
                if only.contains(actionName) {
                    if let response = filter(request: request) {
                        return response
                    }
                }
            }
            // otherwise run filter without any checking
        } else {
            if let response = filter(request: request) {
                return response
            }
        }
        return nil
    }

    public func beforeAction(filter: String, _ options: FilterOptions = nil) -> Void {
        beforeFilters[filter] = options
    }

    public func afterAction(filter: String, _ options: FilterOptions = nil) -> Void {
        afterFilters[filter] = options
    }
}

public func render(template: String) -> Response {
    let body = StencilView(template).render()
    return Response(status: .ok, contentType: .HTML, body: body)
}

public func render(template: String, _ object: HTMLRenderable?) -> Response {
    var body: String
    if let obj = object {
        body = StencilView(template, obj.renderableAttributes()).render()
    } else {
        body = StencilView(template).render()
    }
    return Response(status: .ok, contentType: .HTML, body: body)
}

public func render(template: String, _ context: [String: Any]) -> Response {
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

public func renderJSON(context: [String: Any]? = nil) -> Response {
    let body = JSONView(context).render()
    return Response(status: .ok, contentType: .JSON, body: body)
}

public func redirectTo(path: String) -> Response {
    return Response(status: .found, headers: ["Location": Header(path)])
}

public func respondTo(request: Request, _ responders: [String: () -> Response]) -> Response {
    let accepts = request.headers["Accept"].values
    for (accept, response) in responders {
        if accepts.contains(accept.mimeType()) {
            return response()
        }
    }
    return Response(status: .notAcceptable)
}
