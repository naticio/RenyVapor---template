import Fluent
import FluentPostgresDriver
import Leaf
import Vapor

// configures your application
public func configure(_ app: Application) throws {
    app.logger.logLevel = .debug //to debug
    
    // uncomment to serve files from /Public folder -- TO SEE IMAGES FROM IMAGES FOLDER
    app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    app.databases.use(.postgres(
        hostname: Environment.get("DATABASE_HOST") ?? "localhost",
        port: Environment.get("DATABASE_PORT").flatMap(Int.init(_:)) ?? PostgresConfiguration.ianaPortNumber,
        username: Environment.get("DATABASE_USERNAME") ?? "vapor_username",
        password: Environment.get("DATABASE_PASSWORD") ?? "vapor_password",
        database: Environment.get("DATABASE_NAME") ?? "vapor_database"
    ), as: .psql)

    //create user first because acvronym refers to user!!!
    app.migrations.add(CreateUser())
    app.migrations.add(CreateAcronym())
    app.migrations.add(CreateCategory())
    app.migrations.add(CreateAcronymCategoryPivot())
    

    // register routes
    try routes(app)
    
    //to load the databases in every app launch
    try app.autoMigrate().wait()
    
    app.views.use(.leaf)
}
