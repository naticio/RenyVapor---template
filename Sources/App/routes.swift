import Fluent
import Vapor
import Foundation

func routes(_ app: Application) throws {
    let acronymsController = AcronymsController()
    try app.register(collection: acronymsController)
    
    let userController = UsersController()
    try app.register(collection: userController)
    
    let categoryController = CategoriesController()
    try app.register(collection: categoryController)
    
    let websiteController = WebsiteController()
    try app.register(collection: websiteController)
}
//app.get { req async throws in
//    try await req.view.render("index", ["title": "Hello Vapor!"])
//}
//
////ruta de /hello
//app.get("hello") { req async -> String in
//    "Hello, perrillas!"
//}
//
//
//app.get(":name") { req -> String in
//    let name = try req.parameters.require("name", as: String.self) //get the name
//    return "Hello \(name)"
//}
//
//app.post("info") { req -> InfoResponse in
//    let data = try req.content.decode(InfoData.self) //to parse the json
//    //return "Hello \(data.name)"
//    return InfoResponse(request: data)
//}
//
//app.get("date") { req in
//    return "\(Date())"
//}
//
////:count is to include a parameter, return an struct
//app.get("counter", ":count") { req -> CountJSON in
//    let count = try req.parameters.require("count", as: Int.self)
//    return CountJSON(count: count) //return an struct that has input the number used as parameter
//}
//
//app.post("user-info") { req -> String in //return string because mesg will be "hello name you're 25"
//    let userInfo = try req.content.decode(UserInfoData.self)
//    return "hello \(userInfo.name) you are \(userInfo.age) years old GENIO EXITOSO"
//}
//struct InfoData: Content { //for the post request
//    let name: String
//}
//
//struct InfoResponse: Content {
//    let request: InfoData
//}
//
//struct CountJSON: Content {
//    let count: Int
//}
//
//struct UserInfoData: Content {
//    let name: String
//    let age: Int
//}
