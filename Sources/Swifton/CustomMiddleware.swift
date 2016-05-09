import S4

public protocol CustomMiddleware {
    func call(request: Request, _ closure: (Request) -> Response) -> Response
}
