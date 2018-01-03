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
        
        post ("chat") { req in
//            //Guardem el missatge al array
//            if let text = req.data["messageText"]?.string {
//                let message = Message (userName: "Berni", messageText: text)
//                DataManager.messages.append (message)
//            }
            
            //El printem per pantalla amb leaf
            var messages = [Node] ()
            var isUserSaved = true
            if let userName = req.data["userName"]?.string {
                isUserSaved = false
            }
            
            if isUserSaved {
                let session = try req.assertSession()
                
                guard let userName = session.data["userName"]?.string else {
                    return "error fetching user"
                }
                
                //Guardem el missatge al array
                if let text = req.data["messageText"]?.string {
                    let message = Message (userName: userName, messageText: text)
                    DataManager.messages.append (message)
                }
                
                for message in DataManager.messages {
                    let messageAux = Message (userName: message.userName, messageText: message.messageText)
                    messages.append (try messageAux.makeNode (context: nil))
                }
            } else {
                guard let userName = req.data["userName"]?.string else {return "Error getting user from userAuth"}
                let session = try req.assertSession()
                try session.data.set("userName", userName)
            }
            
            return try self.view.make ("main.leaf", Node (node: ["messages":messages]))
        }
        
        get("chat") {req in
            var messages = [String] ()
            for message in DataManager.messages {
                messages.append (message.messageText)
            }
            return try self.view.make ("main.leaf", ["messages":messages])
        }
        
        get ("userAuth") { req in
            return try self.view.make ("userAuth.leaf")
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
