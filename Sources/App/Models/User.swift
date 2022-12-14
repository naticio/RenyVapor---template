//
//  File.swift
//  
//
//  Created by Nat-Serrano on 12/2/22.
//

import Foundation
import Vapor
import Fluent //to connect to the DB

final class User: Model {
    static let schema = "users" //basically the table name
    
    @ID //so fluent knows it's the id for the model
    var id: UUID?
    
    @Field(key: "name") //equivalent field in the DB
    var name: String
    
    @Field(key: "username")//equivalent field in the DB
    var username: String
    
    //to add the 1 to N relation between user and acronym
    @Children(for: \.$user)
    var acronyms: [Acronym] //1 to many
    
//    @Field(key: "password")
//    var password: String
    
    init() {}
    
    //to initialize the db
    init(id: UUID? = nil, name: String, username: String) {
        self.id = id
        self.name = name
        self.username = username
        //self.password = password
    }
    
    struct Public: Content {
        var id: UUID?
        var name: String
        var username: String
    }

}

//to make acronym conform to CONTENT, and use it in Vapor
extension User: Content {}

////to convert a user struct into a PUblic struct without pwd
//extension User {
//    func convertToPublic() -> User.Public {
//        User.Public(id: self.id, name: self.name, username: self.username)
//    }
//}
//
////to convert a Future user into a Publicv user, usefuil when dealing with future users in route handlers
//extension EventLoopFuture where Value: User {
//    func convertToPublic() -> EventLoopFuture<User.Public> {
//        self.map { user in
//            user.convertToPublic()
//        }
//    }
//}
//
////to convert an array of users into a Publicv user,
//extension Collection where Element: User { //why collection?
//    func convertToPublic() -> [User.Public] {
//        self.map {$0.convertToPublic()} //uses convert to public from the User extension above
//    }
//}
//
////to convert a Future user into an array of PUblic users, usefuil when dealing with future users in route handlers
//extension EventLoopFuture where Value == Array<User> {
//    func convertToPublic() -> EventLoopFuture<[User.Public]> {
//        self.map { $0.convertToPublic()}
//    }
//}
//
////for the authentication feature, to validate the pwd
//
//extension User: ModelAuthenticatable {
//    static let usernameKey = \User.$username
//    static let passwordHashKey = \User.$password
//
//    func verify(password: String) throws -> Bool {
//        try Bcrypt.verify(password, created: self.password)
//    }
//}
