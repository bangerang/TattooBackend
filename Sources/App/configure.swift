import FluentPostgreSQL
import Vapor

/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
	
	/// Register providers first
	try services.register(FluentPostgreSQLProvider())
	
	/// Register routes to the router
	let router = EngineRouter.default()
	try routes(router)
	services.register(router, as: Router.self)
	
	/// Register middleware
	var middlewares = MiddlewareConfig() // Create _empty_ middleware config
	/// middlewares.use(FileMiddleware.self) // Serves files from `Public/` directory
	middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
	services.register(middlewares)
	
	// Configure a database
//	var databases = DatabasesConfig()
//	let databaseName: String
//	let databasePort: Int
//	// 1
//
//	if (env == .testing) {
//		databaseName = "tattootest"
//		databasePort = 5432
//	} else {
//		databaseName = "tattoo"
//		databasePort = 5432
//	}
//	let databaseConfig = PostgreSQLDatabaseConfig(
//		hostname: "localhost",
//		port: databasePort,
//		username: "johanthorell",
//		database: databaseName,
//		password: nil)
//
//	let database = PostgreSQLDatabase(config: databaseConfig)
//	databases.add(database: database, as: .psql)
//
//	services.register(databases)
//

	var databases = DatabasesConfig()
	let databaseConfig: PostgreSQLDatabaseConfig
	if let url = Environment.get("DATABASE_URL") {
	  databaseConfig = PostgreSQLDatabaseConfig(url: url)!
	} else if let url = Environment.get("DB_POSTGRESQL") {
	  databaseConfig = PostgreSQLDatabaseConfig(url: url)!
	} else {
	  let hostname = Environment.get("DATABASE_HOSTNAME") ?? "localhost"
	  let username = Environment.get("DATABASE_USER") ?? "johanthorell"
	  let password = Environment.get("DATABASE_PASSWORD") ?? nil
	  let databaseName: String
	  let databasePort: Int
	  if (env == .testing) {
		databaseName = "tattootest"
		if let testPort = Environment.get("DATABASE_PORT") {
		  databasePort = Int(testPort) ?? 5433
		} else {
		  databasePort = 5432
		}
	  } else {
		databaseName = Environment.get("DATABASE_DB") ?? "vapor"
		databasePort = 5432
	  }

	  databaseConfig = PostgreSQLDatabaseConfig(
		hostname: hostname,
		port: databasePort,
		username: username,
		database: databaseName,
		password: password)
	}
	let database = PostgreSQLDatabase(config: databaseConfig)
	databases.add(database: database, as: .psql)
	services.register(databases)
	
	
	
	/// Configure migrations
	var migrations = MigrationConfig()
	migrations.add(model: Artist.self, database: .psql)
	migrations.add(model: ArtistSettings.self, database: .psql)
	migrations.add(model: Customer.self, database: .psql)
	migrations.add(migration: BookingStatus.self, database: .psql)
	migrations.add(model: Booking.self, database: .psql)
	migrations.add(model: Timeslot.self, database: .psql)
	migrations.add(model: Workplace.self, database: .psql)
	migrations.add(model: TattooSize.self, database: .psql)
	migrations.add(model: WorkDay.self, database: .psql)
	

	services.register(migrations)
	
	let calenderService = CalenderService()
	services.register(calenderService)
	
	let calenderProvider = CalenderProviderMock()
	services.register(calenderProvider, as: CalenderProvider.self)
	
	var commandConfig = CommandConfig.default()
	commandConfig.useFluentCommands()
	services.register(commandConfig)
}
