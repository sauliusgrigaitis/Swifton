import Inquiline

public class ParametersMiddleware: Middleware {
    public func call(request: Request, _ closure: Request -> Response) -> Response {
        var newRequest = request
        var queryString:String = ""
        if Method(rawValue: request.method) == .GET {
            let elements = request.path.split(1, separator: "?")
            if elements.count > 1 {
                queryString = request.path.split(1, separator: "?").last!
            }
        } else { 
            queryString = request.body!
        }

        for keyValue in queryString.split("&") {
            let tokens = keyValue.split(1, separator: "=")
            if let name = tokens.first, value = tokens.last {
                newRequest.params[name.removePercentEncoding()] = value.removePercentEncoding()
            }
        }
        return closure(newRequest)
    } 
}
