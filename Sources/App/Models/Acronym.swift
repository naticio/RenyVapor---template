//
//  File.swift
//  
//
//  Created by Nat-Serrano on 12/1/22.
//

import Foundation
import Vapor
import Fluent //to connect to the DB

final class Acronym: Model {
    static let schema = "acronyms" //basically the table name
    
    @ID //so fluent knows it's the id for the model
    var id: UUID?
    
    @Field(key: "short") //equivalent field in the DB
    var short: String
    
    @Field(key: "long")//equivalent field in the DB
    var long: String
    
    //add userID as foreign key, one to one, an acronym can only have 1 creator
    @Parent(key: "userID")
    var user: User
    
    @Siblings(through: AcronymCategoryPivot.self, from: \.$acronym, to: \.$category)
    var categories: [Category]
    
    init() {}
    
    //to initialize the db
    init(id: UUID? = nil, short: String, long: String, userID: User.IDValue) {
        self.id = id
        self.short = short
        self.long = long
        self.$user.id = userID //do not get the entire user object, just the ID!
    }
    

}

//to make acronym conform to CONTENT, and use it in Vapor
extension Acronym: Content {}
