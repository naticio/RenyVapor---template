//
//  File.swift
//  
//
//  Created by Nat-Serrano on 12/2/22.
//

import Foundation
import Vapor
import Fluent //to connect to the DB

final class Category: Model {
    
    static let schema = "categories" //basically the table name
    
    @ID //so fluent knows it's the id for the model
    var id: UUID?
    
    @Field(key: "name") //equivalent field in the DB
    var name: String

    @Siblings(through: AcronymCategoryPivot.self, from: \.$category, to: \.$acronym)
    var acronyms: [Acronym]
    
    init() {}
    
    //to initialize the db
    init(id: UUID? = nil, name: String) {
        self.id = id
        self.name = name
    }
    

}

//to make acronym conform to CONTENT, and use it in Vapor
extension Category: Content {}
