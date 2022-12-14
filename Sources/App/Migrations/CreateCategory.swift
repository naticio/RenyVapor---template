//
//  File.swift
//  
//
//  Created by Nat-Serrano on 12/2/22.
//
import Fluent

struct CreateCategory: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        //what schema to use
        database.schema("categories")
            .id()
            .field("name", .string, .required)
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("categories").delete() //wtf is this for? to delete the db?

    }
}
