//
//  CustomerController.swift
//  App
//
//  Created by Johan Thorell on 2019-10-17.
//

import Vapor

struct CustomerController: RouteCollection {
	func boot(router: Router) throws {
		let bookingRoute = router.grouped("api", "customers")
		bookingRoute.post(Customer.self, use: createHandler)
		bookingRoute.get(use: getAllHandler)
		bookingRoute.get(Customer.parameter, use: getHandler)
		bookingRoute.put(Customer.parameter, use: putHandler)
		bookingRoute.delete(Customer.parameter, use: deleteHandler)
	}
	
	func createHandler(_ req: Request, customer: Customer) throws -> Future<Customer> {
		return customer.save(on: req)
	}
	
	func getAllHandler(_ req: Request) throws -> Future<[Customer]> {
		return Customer.query(on: req).all()
	}
	
	func getHandler(_ req: Request) throws -> Future<Customer> {
		return try req.parameters.next(Customer.self)
	}
	
	func putHandler(_ req: Request) throws -> Future<Customer> {
		return try req.parameters.next(Customer.self).update(on: req)
	}
	
	func deleteHandler(_ req: Request) throws -> Future<Customer> {
		return try req.parameters.next(Customer.self).delete(on: req)
	}
	
}
