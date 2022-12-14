//
//  File.swift
//  
//
//  Created by Nat-Serrano on 12/4/22.
//

import Fluent

struct CreateAcronymCategoryPivot: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        //what schema to use
        database.schema("acronym-category-pivot")
            .id()
            .field("acronymID", .uuid, .required, .references("acronyms", "id", onDelete: .cascade)) //reference to the external table
            .field("categoryID", .uuid, .required, .references("categories", "id", onDelete: .cascade))//reference to the external table
        //ondelete means that if the external table record gets deleted then also the pivot record will be deleted
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("acronym-category-pivot").delete() //wtf is this for? to delete the db?

    }
}
