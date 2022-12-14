//
//  File.swift
//  
//
//  Created by Nat-Serrano on 12/2/22.
//

//FOR CRUD, IT'S A CONTENT MODEL
import Foundation
import Vapor
import Fluent

struct AcronymsController: RouteCollection {
    
    //to group endpoints?
    func boot(routes: RoutesBuilder) throws {
        let acronymsRoutes = routes.grouped("api", "acronyms")
        acronymsRoutes.get(use: getAllHandler)//very common for rest apis
        acronymsRoutes.post(use: createHandler) //very common for rest apis
        acronymsRoutes.get(":acronymID", use: getHandler)
        acronymsRoutes.delete(":acronymID", use: deleteHandler)
        acronymsRoutes.put(":acronymID", use: updateHandler)
        //using acronymID as parameter return the user associated to it
        acronymsRoutes.get(":acronymID", "user", use: getUserHandler)
        acronymsRoutes.get(":acronymID", "categories", use: getCategoriesHandler)
        //to add category to an acronym
        acronymsRoutes.post(":acronymID", "categories", ":categoryID", use: addCategoriesHandler)
        //searchhandler
        acronymsRoutes.get("search", use: searchHandler)
        
    }
    
    //get endpoint? GET ALL ACRONYMS
    func getAllHandler(_ req: Request) throws -> EventLoopFuture<[Acronym]> { //array of acronyms
        Acronym.query(on: req.db).all()
    }
    
    //post endpoint? CREATE AN ACRONYM
    func createHandler(_ req: Request) throws -> EventLoopFuture<Acronym> {
        //to put the acronym in a json 1 layer format
        let data = try req.content.decode(CreateAcronymData.self)
    
        //put the data into the acronym format
//        let acronym = Acronym(short: data.short, long: data.long, userID: data.userID)
        let acronym = try Acronym(short: data.short, long: data.long, userID: data.userID)
        return acronym.save(on: req.db).map {acronym}
    }
    
    //GET INDIVIDUAL ACRONYM
    func getHandler(_ req: Request) throws -> EventLoopFuture<Acronym> {
        Acronym.find(req.parameters.get("acronymID"), on: req.db).unwrap(or: Abort(.notFound))
    }
    
    //UPDATE ACRONYM without auth
    func updateHandler(_ req: Request) throws -> EventLoopFuture<Acronym> {
        let updateAcronym = try req.content.decode(Acronym.self)
        return Acronym.find(req.parameters.get("acronymID"), on: req.db).unwrap(or: Abort(.notFound))
            .flatMap { acronym in
                acronym.short = updateAcronym.short
                acronym.long = updateAcronym.long
                return acronym.save(on: req.db).map {
                    acronym
                }
            }
    }
    
    
    //DELETE ACRONYM
    func deleteHandler(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
        //get the individual acronym
        Acronym.find(req.parameters.get("acronymID"), on: req.db).unwrap(or: Abort(.notFound))
        //to get the acronym out of the future
            .flatMap { acronym in //takes a future as input
                acronym.delete(on: req.db).transform(to: .noContent) //transform the future and return no content
            }
    }
    
    //gets who the user is who created the acronym
    func getUserHandler(_ req: Request) throws -> EventLoopFuture<User> {
        Acronym.find(req.parameters.get("acronymID"), on: req.db).unwrap(or: Abort(.notFound))
        //flatMap is to get/use the future value
            .flatMap { acronym in
                //using the acronym give me the user associated to it
                acronym.$user.get(on: req.db)//.convertToPublic()
            }
    }
    
    //gets who the user is who created the acronym
    func getCategoriesHandler(_ req: Request) throws -> EventLoopFuture<[Category]> {
        Acronym.find(req.parameters.get("acronymID"), on: req.db).unwrap(or: Abort(.notFound))
        //flatMap is to get/use the future value
            .flatMap { acronym in
                //using the acronym give me the user associated to it
                acronym.$categories.get(on: req.db)
            }
    }
    
    //I don't understand why return an HTTP status as future?
    func addCategoriesHandler(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
        let acronymQuery = Acronym.find(req.parameters.get("acronymID"), on: req.db).unwrap(or: Abort(.notFound))
        let categoryQuery = Category.find(req.parameters.get("categoryID"), on: req.db).unwrap(or: Abort(.notFound))
        
        return acronymQuery.and(categoryQuery).flatMap { acronym, category in
            //basically add a new category
            acronym.$categories.attach(category, on: req.db).transform(to: .created)
        }
    }
    
    
    //SEARCH FUNCTIONALITY!!
    func searchHandler(_ req: Request) throws -> EventLoopFuture<[Acronym]> {
        //guard in case the term is empty
        guard let searchTerm = req.query[String.self, at: "term"] else {
            throw Abort(.badRequest)
        }
        return Acronym.query(on: req.db)
            .group(.or) { or in //group the search to search for the two fields, either short or long
                or.filter(\.$short == searchTerm)
                or.filter(\.$long == searchTerm)
            }.all()
            //filter and return all the SHORT field that matches the search term
    }
}


//to return a beautiful ONE layer json not nested json
struct CreateAcronymData: Content {
    let short: String
    let long: String
    let userID: UUID
}
