import Inquiline

public protocol Middleware {
    func call(request: Request, _ closure: Request -> Response) -> Response
}
