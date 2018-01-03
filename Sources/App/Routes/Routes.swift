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
            guard let text = req.data["messageText"]?.string else {
                throw Abort(.badRequest)
            }
            let message = Message (userName: "Berni", messageText: text)
            DataManager.messages.append (message)
            var ttext = ""
            for message in DataManager.messages {
                ttext += message.messageText
            }
            
            return ttext
        }
        //                <form action="http://localhost:8080/user" method="post">
        
        post ("chat") { req in
            
            guard let text = req.data["messageText"]?.string else {
                throw Abort(.badRequest)
            }
            let message = Message (userName: "Berni", messageText: text)
            DataManager.messages.append (message)
            
            var messages = [String] ()
            for message in DataManager.messages {
                messages.append (message.messageText)
            }
            return try self.view.make ("main.leaf", ["messages":messages])
        }
        
        get("chat") {req in
            var messages = [String] ()
            for message in DataManager.messages {
                messages.append (message.messageText)
            }
            return try self.view.make ("main.leaf", ["messages":messages])
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
