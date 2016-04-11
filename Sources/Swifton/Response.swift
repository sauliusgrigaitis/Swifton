import S4

public enum ContentType: String {
    case HTML = "text/html"
    case JSON = "application/json"
    case Plain = "text/plain"
}

extension Response {

    public var cookies: [String: String] {
        get {
            return storage["swifton-cookies"] as? [String: String] ?? [:]
        }

        set(cookies) {
            storage["swifton-cookies"] = cookies
        }
    }

    public var bodyString: String? {
        var mutatingBody = body
        let buffer = try? mutatingBody.becomeBuffer()
        return buffer?.description
    }

    init(status: Status, contentType: ContentType, body: String) {
        let contentTypeHeaderValue = Header("\(contentType.rawValue); charset=utf8")
        let headers: Headers = ["Content-Type": contentTypeHeaderValue]
        self.init(status: status, headers: headers, body: body.data)
    }

}
