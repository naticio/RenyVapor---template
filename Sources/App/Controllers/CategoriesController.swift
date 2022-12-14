//
//  File.swift
//  
//
//  Created by Nat-Serrano on 12/2/22.
//

import Foundation
import Vapor

struct CategoriesController: RouteCollection {
    
    //to group endpoints?
    func boot(routes: RoutesBuilder) throws {
        let categoriesRoutes = routes.grouped("api", "categories")
        categoriesRoutes.get(use: getAllHandler)//very common for rest apis
        categoriesRoutes.post(use: createHandler) //very common for rest apis
        categoriesRoutes.get(":categoryID", use: getHandler)
        categoriesRoutes.delete(":categoryID", use: deleteHandler)
        categoriesRoutes.put(":categoryID", use: updateHandler)
        categoriesRoutes.get(":categoryID", "acronyms", use: getAcronymsHandler)
    }
    
    //get endpoint? GET ALL catrgories
    func getAllHandler(_ req: Request) throws -> EventLoopFuture<[Category]> {
        Category.query(on: req.db).all()
    }
    
    //post endpoint? CREATE AN ACRONYM
    func createHandler(_ req: Request) throws -> EventLoopFuture<Category> {
        let category = try req.content.decode(Category.self)
        return category.save(on: req.db).map {category}
    }
    
    //GET INDIVIDUAL ACRONYM
    func getHandler(_ req: Request) throws -> EventLoopFuture<Category> {
        Category.find(req.parameters.get("categoryID"), on: req.db).unwrap(or: Abort(.notFound))
    }
    
    //UPDATE ACRONYM
    func updateHandler(_ req: Request) throws -> EventLoopFuture<Category> {
        let updateCategory = try req.content.decode(Category.self)
        return Category.find(req.parameters.get("categoryID"), on: req.db).unwrap(or: Abort(.notFound))
            .flatMap { category in
                category.name = updateCategory.name
                return category.save(on: req.db).map {
                    category
                }
            }
    }
    
    //DELETE ACRONYM
    func deleteHandler(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
        //get the individual acronym
        Category.find(req.parameters.get("categoryID"), on: req.db).unwrap(or: Abort(.notFound))
        //to get the acronym out of the future
            .flatMap { category in //takes a future as input
                category.delete(on: req.db).transform(to: .noContent) //transform the future and return no content
            }
    }
    
    //gets who the user is who created the acronym
    func getAcronymsHandler(_ req: Request) throws -> EventLoopFuture<[Acronym]> {
        Category.find(req.parameters.get("categoryID"), on: req.db).unwrap(or: Abort(.notFound))
        //flatMap is to get/use the future value
            .flatMap { category in
                //using the acronym give me the user associated to it
                category.$acronyms.get(on: req.db)
            }
    }
}
