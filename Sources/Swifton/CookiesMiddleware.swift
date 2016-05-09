import S4

public class CookiesMiddleware: Middleware {

    public func respond(to request: Request, chainingTo next: Responder) throws -> Response {
        var newRequest = request

        if let rawCookie = newRequest.headers["Cookie"].values.first {
            let cookiePairs = rawCookie.split(separator: ";")
            for cookie in cookiePairs {
                let keyValue = cookie.split(separator: "=")
                newRequest.cookies[keyValue[0]] = keyValue[1]
            }
        }

        var response = try next.respond(to: newRequest)
        response.headers["Set-Cookie"] = Header(response.cookies.map { "\($0)=\($1)" }.joined(separator: ";"))
        return response
    }

}
