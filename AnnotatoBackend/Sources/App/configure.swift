import Vapor
import Fluent
import FluentPostgresDriver

// configures your application
public func configure(_ app: Application) throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    connectDatabase(app: app)
    try addAndRunMigrations(app: app)

    // increase default payload size
    app.routes.defaultMaxBodySize = "10mb"

    // register routes
    try routes(app)
}

private func connectDatabase(app: Application) {
    guard let dbHostName = Environment.get("DB_HOSTNAME"),
          let dbUserName = Environment.get("DB_USERNAME"),
          let dbPassword = Environment.get("DB_PASSWORD"),
          let dbName = Environment.get("DB_NAME") else {
              app.logger.error("Database not connected due to missing environment variables")
              return
          }

    let dbConfig = DatabaseConfigurationFactory.postgres(hostname: dbHostName, username: dbUserName,
                                                         password: dbPassword, database: dbName)

    app.databases.use(dbConfig, as: .psql)
}

private func addAndRunMigrations(app: Application) throws {
    app.migrations.add(CreateDocuments())
    app.migrations.add(CreateAnnotations())
    app.migrations.add(CreateAnnotationText())
    app.migrations.add(CreateSelectionBoxes())
    app.migrations.add(CreateDocumentShares())
    app.migrations.add(CreateAnnotationHandwritings())

    try app.autoMigrate().wait()
}
