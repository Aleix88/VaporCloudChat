import Vapor

extension Droplet {
    func setupRoutes() throws {
        get("hello") { req in
            var json = JSON()
            try json.set("hello", "world")
            return json
        }

        get("plaintext") { request in

            return "si"
        }
        
        post ("user") { req in
            if let bodyBytes = req.body.bytes {
                let string = String(bytes: bodyBytes, encoding: String.Encoding.utf8)
                return string!
            }
            return req.description
        }
        
        get("chat") {req in
            return try self.view.make ("main.leaf")
        }

        // response to requests to /info domain
        // with a description of the request
        get("info") { req in
            return req.description
        }

        get("description") { req in return req.description }
        
        try resource("posts", PostController.self)
    }
}
