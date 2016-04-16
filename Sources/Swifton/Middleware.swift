import S4

public protocol Middleware {
    func call(request: Request, _ closure: Request -> Response) -> Response
}
