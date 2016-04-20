import S4

extension Request {

    public var params: [String: String] {
        get {
            var params = pathParameters

            if let swiftonParams = storage["swifton-params"] as? [String: String] {
                for (key, value) in swiftonParams {
                    params[key] = value
                }
            }

            return params
        }

        set(params) {
            storage["swifton-params"] = params
        }
    }

    public var cookies: [String: String] {
        get {
            return storage["swifton-cookies"] as? [String: String] ?? [:]
        }

        set(params) {
            storage["swifton-cookies"] = params
        }
    }

    var bodyString: String? {
        var mutatingBody = body
        let buffer = try? mutatingBody.becomeBuffer()
        return buffer?.description
    }

}
