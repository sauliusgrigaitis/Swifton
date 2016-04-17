import S4

extension Response {
    public var cookies: [String: String] {
        get {
            return storage["swifton-cookies"] as? [String: String] ?? [:]
        }

        set(cookies) {
            storage["swifton-params"] = cookies
        }
    }
}
 
