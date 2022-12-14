import Vapor

struct WebsiteController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        
        routes.get(use: indexHandler)
        routes.get("acronyms", ":acronymID", use: acronymHandler)
        routes.get("users", ":userID", use: userHandler)
        
        routes.get("users", use: allUsersHandler)
        routes.get("categories", use: allCategoriesHandler)
        
        //route to view /acronyms/create...why get all  users?
        routes.get("acronyms", "create", use: createAcronymHandler)
        //to crearte the acronym POST
        routes.post("acronyms", "create", use: createAcronymPostHandler)
        //to route to edit screen
        routes.get("acronyms", ":acronymID", "edit", use: editAcronymHandler)
        //to receive data frmo edit acronym
        routes.post("acronyms", ":acronymID", "edit", use: editAcronymPostHandler)
        //to delete acronym
        routes.post("acronyms", ":acronymID", "delete", use: deleteAcronymHandler)
    }
    
    //landing page
    func indexHandler(_ req: Request) throws -> EventLoopFuture<View> {
        Acronym.query(on: req.db).all().flatMap { acronyms in
            //generate an instance of the data I want to see in my index page
            let context = IndexContext(title: "Homepage", acronyms: acronyms)
            //generate the view
            return req.view.render("index", context)
        }
    }
    
    
    func acronymHandler(_ req: Request) throws -> EventLoopFuture<View> {
        Acronym.find(req.parameters.get("acronymID"), on: req.db).unwrap(or: Abort(.notFound))
            .flatMap { acronym in
                acronym.$user.get(on: req.db).flatMap { user in
                    //double call to bring acronym and user
                    let context = AcronymContext(title: acronym.long, acronym: acronym, user: user)
                    return req.view.render("acronym", context)
                }
            }
    }
    
    func userHandler(_ req: Request) throws -> EventLoopFuture<View> {
        User.find(req.parameters.get("userID"), on: req.db).unwrap(or: Abort(.notFound))
            .flatMap { user in
                user.$acronyms.get(on: req.db).flatMap { acronyms in
                    //double call to bring acronym and user
                    let context = UserContext(title: user.name, acronyms: user.acronyms, user: user)
                    return req.view.render("user", context)
                }
            }
    }
    
    
    func allUsersHandler(_ req: Request) throws -> EventLoopFuture<View> {
        User.query(on: req.db).all().flatMap { users in
            //generate an instance of the data I want to see in my index page
            let context = UsersContext(title: "All Users", users: users)
            //generate the view
            return req.view.render("users", context) //render the leaf page
        }
    }
    
    func allCategoriesHandler(_ req: Request) throws -> EventLoopFuture<View> {
        Category.query(on: req.db).all().flatMap { categories in
            //generate an instance of the data I want to see in my index page
            let context = CategoriesContext(title: "All Categories", categories: categories)
            //generate the view
            return req.view.render("categories", context) //render the leaf page
        }
    }
    
    //to go to the form page to sbumit acronyms, that;s why it's a get
    func createAcronymHandler(_ req: Request) throws -> EventLoopFuture<View> {
        User.query(on: req.db).all().flatMap { users in
            let context = CreateAcronymContext(title: "Create an Acronym", users: users)
            return req.view.render("createAcronym", context)
        }
    }
    
    //to receive data from create acronym screen
    func createAcronymPostHandler(_ req: Request) throws -> EventLoopFuture<Response> {
        let data = try req.content.decode(CreateAcronymData.self)
        let acronym = Acronym(short: data.short, long: data.long, userID: UUID()) //get the data into the struct
        return acronym.save(on: req.db) //save the acronym in the db
            //then redirect to the acronym page, flatmap throwing throws inside the closure wtf?
            .flatMapThrowing {
                let id = try acronym.requireID() //get the acronym id
                return req.redirect(to: "/acronyms/\(id)")
            }
    }
    
    //to redirect to the edit acronym (or create acronym screen as it's reused)
    func editAcronymHandler(_ req: Request) throws -> EventLoopFuture<View> {
        Acronym.find(req.parameters.get("acronymID"), on: req.db).unwrap(or: Abort(.notFound))
            .flatMap { acronym in
                //now get all users, why send all users to the edit screem?
                User.query(on: req.db).all().flatMap { users in
                    let context = EditAcronymContext(title: "Edit Acronym", acronym: acronym, users: users)
                    return req.view.render("createAcronym", context) //why create acronym view? because the view is almost identical so you can reuse a page/view with a different context aka struct
                }
            }
    }
    
    //to receive the data from edit acronym screen
    func editAcronymPostHandler(_ req: Request) throws -> EventLoopFuture<Response> {
        let updatedData = try req.content.decode(CreateAcronymData.self)
        //why return immediately?
        return Acronym.find(req.parameters.get("acronymID"), on: req.db).unwrap(or: Abort(.notFound)).flatMap { acronym in
            //update with new values
            acronym.short = updatedData.short
            acronym.short = updatedData.long
            //acronym.$user.id = updatedData.userID
            acronym.$user.id = UUID() //if you don't want to use auth then use the prev line
            //redirect to acronym page
            return acronym.save(on: req.db).flatMapThrowing {
                let id = try acronym.requireID()
                return req.redirect(to: "/acronyms/\(id)")
            }
        }
    }
    
    //to receive the data from edit acronym screen
    func deleteAcronymHandler(_ req: Request) throws -> EventLoopFuture<Response> {
        Acronym.find(req.parameters.get("acronymID"), on: req.db).unwrap(or: Abort(.notFound))
            .flatMap { acronym in
                acronym.delete(on: req.db).transform(to: req.redirect(to: "/")) //transform redirects
            }
    }
    
}

//to hold the data for the index page
struct IndexContext: Encodable {
    let title: String
    let acronyms: [Acronym]
}

struct AcronymContext: Encodable {
    let title: String
    let acronym: Acronym
    let user: User
}

//to hold user data
struct UserContext: Encodable {
    let title: String
    let acronyms: [Acronym]
    let user: User
}

//to hold users data
struct UsersContext: Encodable {
    let title: String
    let users: [User]
}

//to hold users data
struct CategoriesContext: Encodable {
    let title: String
    let categories: [Category]
}

//to create acronyms
struct CreateAcronymContext: Encodable {
    let title: String
    let users: [User]
}

//for the edit acronym screen view
struct EditAcronymContext: Encodable {
    let title: String
    let acronym: Acronym
    let users: [User]
    let editing = true
}
