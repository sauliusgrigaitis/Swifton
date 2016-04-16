import S4

public class CookiesMiddleware: Middleware {
    public func call(request: Request, _ closure: Request -> Response) -> Response {
        var newRequest = request
        if let rawCookie = newRequest["Cookie"] {
            let cookiePairs = rawCookie.split(";")
            for cookie in cookiePairs {
                let keyValue = cookie.split("=")
                newRequest.cookies[keyValue[0]] = keyValue[1]
            }
        }

        var response = closure(newRequest)

        response["Set-Cookie"] = response.cookies.map { $0 + "=" + $1 }.joined(separator: ";")
        return response
    }
}
