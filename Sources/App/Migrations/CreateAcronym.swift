//
//  File.swift
//  
//
//  Created by Nat-Serrano on 12/1/22.
//

//import Foundation
import Fluent

struct CreateAcronym: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        //what schema to use
        database.schema("acronyms")
            .id()
            .field("short", .string, .required)
            .field("long", .string, .required)
            .field("userID", .uuid, .required, .references("users", "id")) //link to the user schema
            .create()
        
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("acronyms").delete() //wtf is this for? to delete the db?

    }
}
