import Inquiline
import String

public class ParametersMiddleware: Middleware {
    public func call(request: Request, _ closure: Request -> Response) -> Response {
        var newRequest = request
        var queryString: String = ""
        if Method(rawValue: request.method) == .GET {
            let elements = request.path.split("?", maxSplits: 1)
            if elements.count > 1 {
                queryString = request.path.split("?", maxSplits: 1).last!
            }
        } else {
            queryString = request.body!
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
        newRequest.method = self.resolveMethod(newRequest)
        return closure(newRequest)
    }

    func resolveMethod(request: Request) -> String {
        if request.method == "POST" {
            if let paramsMethod = request.params["_method"] {
                let paramsMethod = paramsMethod.uppercased()
                if ["DELETE", "HEAD", "PATCH", "PUT", "OPTIONS"].contains(paramsMethod) {
                    return paramsMethod
                }
            }
        }
        return request.method
    }
}
