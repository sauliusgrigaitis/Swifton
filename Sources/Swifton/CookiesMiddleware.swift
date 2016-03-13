import Inquiline

public class CookiesMiddleware: Middleware {
    public func call(request: Request, _ closure: Request -> Response) -> Response {
        var newRequest = request
        if let rawCookie = newRequest["Cookie"] {
            let cookiePairs = rawCookie.characters.split(";").flatMap(String.init)
            for cookie in cookiePairs {
                let keyValue = cookie.characters.split("=").flatMap(String.init)
                newRequest.cookies[keyValue[0]] = keyValue[1]
            }
        }

        var response = closure(newRequest)

        response["Set-Cookie"] = response.cookies.map { $0 + "=" + $1 }.joinWithSeparator(";")
        return response
    } 
}
