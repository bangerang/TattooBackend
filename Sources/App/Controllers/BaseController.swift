//
//  BaseController.swift
//  App
//
//  Created by Johan Thorell on 2019-10-18.
//

import Vapor
import FluentPostgreSQL

extension String: Error {}

class BaseController<C: Content & PostgreSQLUUIDModel & Parameter>: RouteCollection {
	
	var route: Router!
	var domain: [PathComponentsRepresentable]
	
	required init(domain: [PathComponentsRepresentable]) {
		self.domain = domain
	}
	
	func boot(router: Router) throws {
		domain.insert("api", at: 0)
		route = router.grouped(domain)
		route.post(C.self, use: createHandler)
		route.get(use: getAllHandler)
		route.get(C.parameter, use: getHandler)
		route.put(C.self, use: putHandler)
		route.delete(C.parameter, use: deleteHandler)
	}
	
	func createHandler(_ req: Request, model: C) throws -> Future<C> {
		return model.save(on: req)
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
