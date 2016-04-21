import Foundation
import S4
import URITemplate
import PathKit

public class Router {
    public typealias Action = (Request) -> Response
    typealias Route = (URITemplate, S4.Method, Action)

    var routes = [Route]()

    public init() {}

    func notFound(request: Request) -> Response {
        return Response(status: .notFound, contentType: .Plain, body: "Route Not Found")
    }

    func permissionDenied(request: Request) -> Response {
        return Response(status: .notFound, contentType: .Plain, body: "Can't Open File. Permission Denied")
    }

    func errorReadingFromFile(request: Request) -> Response {
        return Response(status: .notFound, contentType: .Plain, body: "Error Reading From File")
    }

    public func resources(name: String, _ controller: Controller) {
        let name = "/" + name
        get(name + "/new", controller["new"])
        get(name + "/{id}", controller["show"])
        get(name + "/{id}/edit", controller["edit"])
        get(name, controller["index"])
        post(name, controller["create"])
        delete(name + "/{id}", controller["destroy"])
        patch(name + "/{id}", controller["update"])
    }

    public func delete(uri: String, _ action: Action) {
        routes.append((URITemplate(template: uri), .delete, action))
    }

    public func get(uri: String, _ action: Action) {
        routes.append((URITemplate(template: uri), .get, action))
    }

    public func head(uri: String, _ action: Action) {
        routes.append((URITemplate(template: uri), .head, action))
    }

    public func patch(uri: String, _ action: Action) {
        routes.append((URITemplate(template: uri), .patch, action))
    }

    public func post(uri: String, _ action: Action) {
        routes.append((URITemplate(template: uri), .post, action))
    }

    public func put(uri: String, _ action: Action) {
        routes.append((URITemplate(template: uri), .put, action))
    }

    public func options(uri: String, _ action: Action) {
        routes.append((URITemplate(template: uri), .options, action))
    }

    public func respond(request: Request) -> Response {
        return ParametersMiddleware().call(request) {
          CookiesMiddleware().call($0, self.resolveRoute)
        }
    }

    public func resolveRoute(request: Request) -> Response {
        var newRequest = request

        for (template, method, handler) in routes {
            if newRequest.method == method {
                if let variables = template.extract(newRequest.uri.path!) {
                    for (key, value) in variables {
                        newRequest.params[key] = value
                    }
                    return handler(newRequest)
                }
            }
        }

        if let staticFile = serveStaticFile(newRequest) {
            return staticFile
        }

        return notFound(newRequest)
    }

    func serveStaticFile(request: Request) -> Response? {
        if request.uri.path != "/" {
            let publicPath = Path(SwiftonConfig.publicDirectory)
            if publicPath.exists && publicPath.isDirectory {
                let filePath = publicPath + String(request.uri.path!.characters.dropFirst())
                if filePath.exists {
                    if filePath.isReadable {
                        do {
                            let contents: NSData? = try filePath.read()
                            if let body = String(data:contents!, encoding: NSUTF8StringEncoding) {
                                return Response(status: .ok, contentType: .Plain, body: body)
                            }
                        } catch {
                            return errorReadingFromFile(request)
                        }
                    } else {
                        return permissionDenied(request)
                    }
                }
            }
        }
        return nil
    }
}
