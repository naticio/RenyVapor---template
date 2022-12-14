//
//  File.swift
//  
//
//  Created by Nat-Serrano on 12/2/22.
//

import Fluent

struct CreateUser: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        //what schema to use
        database.schema("users")
            .id()
            .field("name", .string, .required)
            .field("username", .string, .required)
            //.field("password", .string, .required)
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("users").delete() //wtf is this for? to delete the db?

    }
}

