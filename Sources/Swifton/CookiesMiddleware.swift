import S4

public class CookiesMiddleware: CustomMiddleware {

    public func call(request: Request, _ closure: Request -> Response) -> Response {
        var newRequest = request
        if let rawCookie = newRequest.headers["Cookie"].values.first {
            let cookiePairs = rawCookie.split(";")
            for cookie in cookiePairs {
                let keyValue = cookie.split("=")
                newRequest.cookies[keyValue[0]] = keyValue[1]
            }
        }

        var response = closure(newRequest)
        response.headers["Set-Cookie"] = Header(response.cookies.map { "\($0)=\($1)" }.joined(separator: ";"))
        return response
    }

}
