import Foundation
import S4
@_exported import Router
import PathKit

extension Router {

    public static func create(build: (route: RouterBuilder) -> Void) -> Router {
        return self.init(middleware: ParametersMiddleware(), CookiesMiddleware()) { route in
            route.fallback { request in
                if let staticFile = serveStaticFile(request: request) {
                    return staticFile
                } else {
                    return Response(status: .notFound, body: "Route Not Found")
                }
            }

            build(route: route)
        }
    }

    static func serveStaticFile(request: Request) -> Response? {
        guard request.uri.path != "/" else { return nil }

        let publicPath = Path(SwiftonConfig.publicDirectory)
        guard publicPath.exists && publicPath.isDirectory else { return nil }

        let filePath = publicPath + String(request.uri.path!.characters.dropFirst())
        guard filePath.exists else { return nil }

        guard filePath.isReadable else {
            return Response(status: .notFound, body: "Can't Open File. Permission Denied")
        }

        do {
            let contents = try filePath.read()
            var contentType = ContentType.Plain
            if let fileExtension = filePath.`extension`, let contentTypeRaw = Swifton.mimeTypes[fileExtension], let resolvedContentType = ContentType(rawValue: contentTypeRaw) {
                contentType = resolvedContentType
            }
            if let body = String(data: contents, encoding: NSUTF8StringEncoding) {
                return Response(status: .ok, contentType: contentType, body: body)
            }
        } catch {
            return Response(status: .notFound, body: "Error Reading From File")
        }

        return nil
    }

}

extension RouterBuilder {

    public func resources(_ path: String, middleware: Middleware..., controller: Controller) {
        get(path, respond: controller["index"])
        get("\(path)/new", respond: controller["new"])
        get("\(path)/:id", respond: controller["show"])
        post("\(path)", respond: controller["create"])
        get("\(path)/:id/edit", respond: controller["edit"])
        patch("\(path)/:id", respond: controller["update"])
        delete("\(path)/:id", respond: controller["destroy"])
    }

}
