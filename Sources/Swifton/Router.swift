import Inquiline
import Nest
import Foundation
import PathKit
import URITemplate

public enum Method:String {
    case DELETE = "DELETE"
    case GET = "GET"
    case HEAD = "HEAD"
    case PATCH = "PATCH"
    case POST = "POST"
    case PUT = "PUT"
    case OPTIONS = "OPTIONS"
}

public class Router {
    public typealias Action = (Request) -> Response
    typealias Route = (URITemplate, Method, Action)

    var routes = [Route]()
    
    public init() {}

    public var notFound: Nest.Application = { request in
        return Response(.NotFound, contentType: "text/plain; charset=utf8", body: "Route Not Found")
    }

    public var permissionDenied: Nest.Application = { request in
        return Response(.NotFound, contentType: "text/plain; charset=utf8", body: "Can't Open File. Permission Denied")
    }

    public var errorReadingFromFile: Nest.Application = { request in
        return Response(.NotFound, contentType: "text/plain; charset=utf8", body: "Error Reading From File")
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
        routes.append((URITemplate(template: uri), .DELETE, action))
    }

    public func get(uri: String, _ action: Action) {
        routes.append((URITemplate(template: uri), .GET, action))
    }

    public func head(uri: String, _ action: Action) {
        routes.append((URITemplate(template: uri), .HEAD, action))
    }

    public func patch(uri: String, _ action: Action) {
        routes.append((URITemplate(template: uri), .PATCH, action))
    }

    public func post(uri: String, _ action: Action) {
        routes.append((URITemplate(template: uri), .POST, action))
    }

    public func put(uri: String, _ action: Action) {
        routes.append((URITemplate(template: uri), .PUT, action))
    }

    public func options(uri: String, _ action: Action) {
        routes.append((URITemplate(template: uri), .OPTIONS, action))
    }

    public func respond(requestType: RequestType) -> ResponseType {
         let request = requestType as? Request ?? Request(method: requestType.method, path: requestType.path, headers: requestType.headers, body: requestType.body)
        return ParametersMiddleware().call(request, resolveRoute)
    }

    public func resolveRoute(request: Request) -> Response {
        var newRequest = request
        newRequest.method = resolveMethod(newRequest)
                
        for (template, method, handler) in routes {
            if newRequest.method == method.rawValue {
                if let variables = template.extract(newRequest.path) {
                    for (key, value) in variables {
                        newRequest.params[key] = value
                    }
                    return handler(newRequest)
                }
            }
        }

        if let staticFile = serveStaticFile(newRequest) {
            return staticFile as! Response
        }

        return notFound(newRequest) as! Response
    }

    func serveStaticFile(request: Request) -> ResponseType? {
        if request.path != "/" {
            let publicPath = Path(SwiftonConfig.publicDirectory)
            if publicPath.exists && publicPath.isDirectory {
                let filePath = publicPath + String(request.path.characters.dropFirst())
                if filePath.exists {
                    if filePath.isReadable {
                        do {
                            let contents:NSData? = try filePath.read()
                            if let body = String(data:contents!, encoding: NSUTF8StringEncoding) {
                                return Response(.Ok, contentType: "text/plain; charset=utf8", body: body)
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


    func resolveMethod(request: Request) -> String {
        if request.method == "POST" {
            if let paramsMethod = request.params["_method"] {
                let paramsMethod = paramsMethod.uppercaseString
                if ["DELETE", "HEAD", "PATCH", "PUT", "OPTIONS"].contains(paramsMethod) {
                    return paramsMethod
                }
            }
        }
        return request.method
    }
}
