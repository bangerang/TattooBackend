//
//  Application+Testable.swift
//  AppTests
//
//  Created by Johan Thorell on 2019-10-15.
//

import Vapor
import App
import FluentPostgreSQL

extension Application {
	static func testable(envArgs: [String]? = nil) throws -> Application {
		var config = Config.default()
		var services = Services.default()
		var env = Environment.testing

		if let environmentArgs = envArgs {
			env.arguments = environmentArgs
		}

		try App.configure(&config, &env, &services)
		let app = try Application(config: config, environment: env, services: services)

		try App.boot(app)
		return app
	}
	static func reset() throws {
		let revertEnvironment = ["vapor", "revert", "--all", "-y"]
		try Application.testable(envArgs: revertEnvironment).asyncRun().wait()
		let migrateEnvironment = ["vapor", "migrate", "-y"]
		try Application.testable(envArgs: migrateEnvironment).asyncRun().wait()
	}
	// 1
	func sendRequest<T>(to path: String, method: HTTPMethod, headers: HTTPHeaders = .init(),
						body: T? = nil) throws -> Response where T: Content {
	  let responder = try self.make(Responder.self)
	  // 2
	  let request = HTTPRequest(method: method, url: URL(string: path)!,
								headers: headers)
	  let wrappedRequest = Request(http: request, using: self)
	  // 3
	  if let body = body {
		try wrappedRequest.content.encode(body)
	  }
	  // 4
	  return try responder.respond(to: wrappedRequest).wait()
	}

	// 5
	func sendRequest(to path: String, method: HTTPMethod,
					 headers: HTTPHeaders = .init()) throws -> Response {
	  // 6
	  let emptyContent: EmptyContent? = nil
	  // 7
	  return try sendRequest(to: path, method: method, headers: headers,
							 body: emptyContent)
	}

	// 8
	func sendRequest<T>(to path: String, method: HTTPMethod, headers: HTTPHeaders,
						data: T) throws where T: Content {
	  // 9
	  _ = try self.sendRequest(to: path, method: method, headers: headers,
							   body: data)
	}
	
	// 1
	func getResponse<C,T>(to path: String, method: HTTPMethod = .GET,
						  headers: HTTPHeaders = .init(), data: C? = nil,
						  decodeTo type: T.Type) throws -> T where C: Content, T: Decodable {
	  // 2
	  let response = try self.sendRequest(to: path, method: method,
										  headers: headers, body: data)
	  // 3
	  return try response.content.decode(type).wait()
	}

	// 4
	func getResponse<T>(to path: String, method: HTTPMethod = .GET,
						headers: HTTPHeaders = .init(),
						decodeTo type: T.Type) throws -> T where T: Decodable {
	  // 5
	  let emptyContent: EmptyContent? = nil
	  // 6
	  return try self.getResponse(to: path, method: method, headers: headers,
								  data: emptyContent, decodeTo: type)
	}
}
struct EmptyContent: Content {}
