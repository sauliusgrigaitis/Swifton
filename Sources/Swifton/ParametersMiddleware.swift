import S4
import String

public class ParametersMiddleware: CustomMiddleware {

    public func call(request: Request, _ closure: Request -> Response) -> Response {
        var newRequest = request
        var queryString = ""

        if request.method == .get {
            if let elements = request.uri.path?.split("?", maxSplits: 1) {
                if let query = elements.last {
                    queryString = query
                }
            }
        } else {
            if let body = request.bodyString {
                queryString = body
            }
        }

        for keyValue in queryString.split("&") {
            let tokens = keyValue.split("=", maxSplits: 1)
            if let name = tokens.first, value = tokens.last {
                if let parsedName = try? String(percentEncoded: name),
                    let parsedValue = try? String(percentEncoded: value) {
                    newRequest.params[parsedName] = parsedValue
                }
            }
        }

        newRequest.method = resolveMethod(newRequest)
        return closure(newRequest)
    }

    func resolveMethod(request: Request) -> S4.Method {
        guard request.method == .post else { return request.method }
        guard let paramsMethod = request.params["_method"] else { return request.method }

        switch paramsMethod.uppercased() {
        case "DELETE":
            return .delete
        case "HEAD":
            return .head
        case "PATCH":
            return .patch
        case "PUT":
            return .put
        case "OPTIONS":
            return .options
        default:
            return request.method
        }
    }

}
