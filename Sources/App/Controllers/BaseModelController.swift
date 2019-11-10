//
//  BaseController.swift
//  App
//
//  Created by Johan Thorell on 2019-10-18.
//

import Vapor
import FluentPostgreSQL

extension String: Error {}

enum HTTPMethods {
	case get
	case put
	case post
	case delete
}
class BaseModelController<C: Content & PostgreSQLUUIDModel & Parameter>: RouteCollection {
	
	var route: Router!
	var domain: [PathComponentsRepresentable]
	var httpMethods = Set<HTTPMethods>()

	
	required init(domain: [PathComponentsRepresentable], httpMethods: Set<HTTPMethods>) {
		self.domain = domain
		self.httpMethods = httpMethods
	}
	
	private func addRoutes() {
		httpMethods.forEach {
			switch $0 {
			case .get:
				route.get(use: getAllHandler)
				route.get(C.parameter, use: getHandler)
			case .put:
				route.put(C.self, use: putHandler)
			case .post:
				route.post(C.self, use: createHandler)
				let many = route.grouped("many")
				many.post([C].self, use: createHandlerMany)
			case .delete:
				route.delete(C.parameter, use: deleteHandler)
			}
		}

	}
	
	func boot(router: Router) throws {
		domain.insert("api", at: 0)
		route = router.grouped(domain)
		addRoutes()
	}
	
	func createHandler(_ req: Request, model: C) throws -> Future<C> {
		return model.save(on: req)
	}
	
	func createHandlerMany(_ req: Request, models: [C]) throws -> Future<[C]> {
		return models.map {
			$0.save(on: req)
		}.flatten(on: req)
	}
	
	func getAllHandler(_ req: Request) throws -> Future<[C]> {
		return C.query(on: req).all()
	}
	
	func getHandler(_ req: Request) throws -> Future<C> {
		guard let promise = try req.parameters.next(C.self) as? EventLoopFuture<C> else {
			throw "Failed to cast type to EventLoopFuture<C>"
		}
		return promise
	}
	
	func putHandler(_ req: Request, model: C) throws -> Future<C> {
		return model.update(on: req)
	}
	
	func deleteHandler(_ req: Request) throws -> Future<C> {
		guard let promise = try req.parameters.next(C.self) as? EventLoopFuture<C> else {
			throw "Failed to cast type to EventLoopFuture<C>"
		}
		return promise.delete(on: req)
	}
	
}
