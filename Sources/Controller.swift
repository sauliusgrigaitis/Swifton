import Inquiline

public class Controller {
    public typealias Parameters = [String: String]
    public typealias Action = (request: Request) -> Response
    public typealias Filter = (request: Request) -> ()
    public typealias FilterCollection = [String: FilterOptions]
    public typealias FilterOptions = [String: [String]]?

    static var applicationController = Controller()
    var actions = [String: Action]()
    var filters = [String: Filter]()
    var beforeFilters = FilterCollection()
    var afterFilters = FilterCollection()

    public init() {}

    public func action(name: String, body: Action) {
        actions[name] = body
    }

    public func filter(name: String, body: Filter) {
        filters[name] = body
    }

    subscript(actionName: String) -> Action {
        get {
            return { (request) in
                guard let action = self.actions[actionName] else { 
                    return Response(.NotFound, contentType: "text/plain; charset=utf8", body: "Action Not Found")
                }
         
                self.runFilters(request, actionName, self.beforeFilters) 
                let response = action(request: request)
                self.runFilters(request, actionName, self.afterFilters) 

                return response
            }
        }

        set(newValue) {
            actions[actionName] = newValue
        }
    }

    func runFilters(request: Request, _ actionName: String, _ filterCollection: FilterCollection) {
        for (filter, options) in filterCollection {
            // prefer filter in child controller
            if let selectedFilter = self.filters[filter] {
                // if "only" option is used then check if action is in the list
                if let opts = options, let only = opts["only"] {
                    if only.contains(actionName) { 
                        selectedFilter(request: request)
                    }
                    // otherwise run filter without any checking
                } else {
                    selectedFilter(request: request)
                }
            // use ApplicationController filter if it's not defined in child controller
            } else if let selectedFilter = Controller.applicationController.filters[filter] {
                selectedFilter(request: request)
            }
        }
    }

    public func beforeAction(filter: String, _ options: FilterOptions = nil) -> Void {
        beforeFilters[filter] = options
    }

    public func afterAction(filter: String, _ options: FilterOptions = nil) -> Void {
        afterFilters[filter] = options   
    }

    public func render(template: String) -> Response {
        let body = StencilView(template).render()
        return Response(.Ok, contentType: "text/html", body: body)
    }

    public func render(template: String, _ object: HTMLRenderable?) -> Response {
        var body:String
        if let obj = object {
            body = StencilView(template, obj.renderableAttributes()).render()
        } else {
            body = StencilView(template).render()
        }
        return Response(.Ok, contentType: "text/html", body: body)
    }

    public func render(template: String, _ context: [String: Any]) -> Response {
        var body:String
        body = StencilView(template, context).render()
        return Response(.Ok, contentType: "text/html", body: body)
    }

    public func renderJSON(object: JSONRenderable?) -> Response {
        var body:String
        if let obj = object {
            body = JSONView(obj.renderableJSONAttributes()).render()
        } else {
            body = "null"
        }
        return Response(.Ok, contentType: "text/html", body: body)
    }

    public func renderJSON(context: [String: Any]? = nil) -> Response {
        var body:String
        body = JSONView(context).render()
        return Response(.Ok, contentType: "application/json", body: body)
    }

    public func redirectTo(path: String) -> Response {
        return Response(.Found, headers: [("Location", path)])
    }

    public func respondTo(request: Request, _ responders: [String: () -> Response]) -> Response {
        let accepts = request.accept!.split(",")
        for (accept, response) in responders {
            if accepts.contains(accept.mimeType()) {
                return response()
            }
        }
        return Response(.NotAcceptable)
    }
}

