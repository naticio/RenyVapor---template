//
//  File.swift
//  
//
//  Created by Nat-Serrano on 12/4/22.
//


//BASICALLY TO ACT AS LIASON BETWEEN ACRONYMS AND CATEGORIES,
import Fluent
import Vapor
import Foundation

final class AcronymCategoryPivot: Model {
    //static var schema: String
    
    static let schema = "acronym-category-pivot" //basically the table name
    
    @ID //so fluent knows it's the id for the model
    var id: UUID?
    
    //two parent properties to make the link
    @Parent(key: "acronymID")
    var acronym: Acronym
    
    @Parent(key: "categoryID")
    var category: Category //why the whole model and not just the field?
    
    
    init() {}
    
    //to initialize the db
    init(id: UUID? = nil, acronym: Acronym, category: Category) throws {
        self.id = id
        self.$acronym.id = try acronym.requireID() //gets the id for the object
        self.$category.id = try category.requireID()//gets the id for the object
    }
    
    
}

//to make acronym conform to CONTENT, and use it in Vapor
extension AcronymCategoryPivot: Content {}
