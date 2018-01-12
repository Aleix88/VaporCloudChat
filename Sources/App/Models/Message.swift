import Vapor
import FluentProvider
import HTTP

final class Message: Model {
    let storage = Storage()
    
    var id: Node?
    var exists = false
    
    var userName: String
    var messageText: String
    var owner: String
    
    struct Keys {
        static let id = "id"
        static let userName = "userName"
        static let messageText = "messageText"
        static let owner = "owner"
    }
    
    init (userName: String, messageText: String, owner: String = "notOwner") {
        self.userName = userName
        self.messageText = messageText
        self.owner = owner
    }
    
    init (node: Node, in context: Context) throws {
        id = try node.get (Message.Keys.id)
        userName = try node.get (Message.Keys.userName)
        messageText = try node.get(Message.Keys.messageText)
        owner = try node.get(Message.Keys.owner)
    }
    
    func makeNode (context: Context?) throws -> Node {
        var node = Node(context)
        try node.set(Message.Keys.id, id)
        try node.set(Message.Keys.userName, userName)
        try node.set(Message.Keys.messageText, messageText)
        try node.set(Message.Keys.owner, owner)

        return node
    }
    
    static func prepare(_ database: Database) throws {
        try database.create(self) { (message) in
            message.id()
            message.string(Message.Keys.userName)
            message.custom(Message.Keys.messageText, type: "text")
            message.string (Message.Keys.owner)
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
    
    // MARK: Fluent Serialization
    
    /// Initializes the Post from the
    /// database row
    init(row: Row) throws {
        userName = try row.get(Message.Keys.userName)
        messageText = try row.get(Message.Keys.messageText)
        owner = try row.get(Message.Keys.owner)
    }
    
    // Serializes the Post to the database
    func makeRow() throws -> Row {
        var row = Row()
        try row.set(Message.Keys.userName, userName)
        try row.set(Message.Keys.messageText, messageText)
        try row.set(Message.Keys.owner, owner)
        return row
    }

}

// MARK: JSON

// How the model converts from / to JSON.
// For example when:
//     - Creating a new Post (POST /posts)
//     - Fetching a post (GET /posts, GET /posts/:id)
//
extension Message: JSONConvertible {
    convenience init(json: JSON) throws {
        self.init(
            userName: try json.get(Message.Keys.userName),
            messageText: try json.get(Message.Keys.messageText),
            owner: try json.get(Message.Keys.owner)

        )
    }
    
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set(Message.Keys.id, id)
        try json.set(Message.Keys.messageText, messageText)
        try json.set(Message.Keys.userName, userName)
        try json.set(Message.Keys.owner, owner)

        return json
    }
}


