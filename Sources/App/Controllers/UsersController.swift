//
//  File.swift
//  
//
//  Created by Nat-Serrano on 12/2/22.
//

//import Foundation
import Vapor
//import Fluent

struct UsersController: RouteCollection {
    
    //to group endpoints?
    func boot(routes: RoutesBuilder) throws {
        let usersRoutes = routes.grouped("api", "users")
        usersRoutes.get(use: getAllHandler)//very common for rest apis
        usersRoutes.post(use: createHandler) //very common for rest apis
        usersRoutes.get(":userID", use: getHandler)
        usersRoutes.delete(":userID", use: deleteHandler)
        usersRoutes.put(":userID", use: updateHandler)
        usersRoutes.get(":userID", "acronyms", use: getAcronymsHandler)

    }
    
    //get endpoint? GET ALL user
    func getAllHandler(_ req: Request) throws -> EventLoopFuture<[User]> { //array of acronyms
        User.query(on: req.db).all()//.convertToPublic()
    }
    
    //post endpoint? CREATE AN user
    func createHandler(_ req: Request) throws -> EventLoopFuture<User> {
        let user = try req.content.decode(User.self)
        //user.password = try Bcrypt.hash(user.password) //to encrypt the pwd
        return user.save(on: req.db).map {user} //to remove the damn pwd from the user struct
    }
    
    //GET INDIVIDUAL ACRONYM
    func getHandler(_ req: Request) throws -> EventLoopFuture<User> {
        User.find(req.parameters.get("userID"), on: req.db).unwrap(or: Abort(.notFound))
    }
    
    //UPDATE ACRONYM
    func updateHandler(_ req: Request) throws -> EventLoopFuture<User> {
        let updateUser = try req.content.decode(User.self)
        return User.find(req.parameters.get("userID"), on: req.db).unwrap(or: Abort(.notFound))
            .flatMap { user in
                user.name = updateUser.name
                user.username = updateUser.username
                return user.save(on: req.db).map {
                    user
                }
            }
    }
    
    //DELETE ACRONYM
    func deleteHandler(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
        //get the individual user
        User.find(req.parameters.get("userID"), on: req.db).unwrap(or: Abort(.notFound))
        //to get the acronym out of the future
            .flatMap { user in //takes a future as input
                user.delete(on: req.db).transform(to: .noContent) //transform the future and return no content
            }
    }
    
    //get all acronyms that pertain to certain user
    func getAcronymsHandler(_ req: Request) throws -> EventLoopFuture<[Acronym]> {
        User.find(req.parameters.get("userID"), on: req.db).unwrap(or: Abort(.notFound))
            .flatMap { user in
                user.$acronyms.get(on: req.db)
            }
    }
    
}
