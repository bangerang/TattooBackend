//
//  ModelTests.swift
//  AppTests
//
//  Created by Johan Thorell on 2019-10-17.
//

import XCTest
import Vapor
import FluentPostgreSQL

enum TestCase {
	case retrieveAll
	case saved
	case retrieveOne
	case updated
}
class ModelTests<T: Content & Decodable & PostgreSQLUUIDModel>: XCTestCase {
	
	var app: Application!
	var conn: PostgreSQLConnection!
	
	override func setUp() {
		try! Application.reset()
		app = try! Application.testable()
		conn = try! app.newConnection(to: .psql).wait()
	}
	
	override func tearDown() {
		conn.close()
		try? app.syncShutdownGracefully()
	}
	
	func getURI() -> String {
		fatalError("Must override")
	}
	
	func getModel() -> T {
		fatalError("Must override")
	}
	
	func willPerformUpdatenOn(_ model: T) -> T {
		fatalError("Must override")
	}
	func didRecieveModel(_ model: T, testCase: TestCase) {
		fatalError("Must override")
	}
	
	func didRecieveModel(_ model: [T], testCase: TestCase) {
		fatalError("Must override")
	}
	
	
	func testModelCanBeRetrievedByAPI() throws {
		_ = try T.create(model: getModel(), on: conn)
		
		let models = try app.getResponse(to: getURI(), decodeTo: [T].self)
		didRecieveModel(models, testCase: .retrieveAll)
	}
	
	func testModelCanBeSavedbyAPI() throws {
		
		let receivedModel = try app.getResponse(
			to: getURI(),
			method: .POST,
			headers: ["Content-Type": "application/json"],
			data: getModel(),
			decodeTo: T.self)
		
		didRecieveModel(receivedModel, testCase: .saved)
		
		let allModels = try app.getResponse(to: getURI(), decodeTo: [T].self)
		didRecieveModel(allModels, testCase: .retrieveAll)

	}
	func testGettingASingleModelEntryFromAPI() throws {
		let createdModel = try T.create(model: getModel(), on: conn)
		
		let receivedModel = try app.getResponse(to: "\(getURI())\(createdModel.id!)", decodeTo: T.self)
		didRecieveModel(receivedModel, testCase: .retrieveOne)
		
	}
	func testModelCanBeUpdatedByAPI() throws {
		
		var createdModel = try T.create(model: getModel(), on: conn)
		
		createdModel = willPerformUpdatenOn(createdModel)
		
		let receivedModel = try app.getResponse(
			to: "\(getURI())",
			method: .PUT,
			headers: ["Content-Type": "application/json"],
			data: createdModel,
			decodeTo: T.self)
		
		didRecieveModel(receivedModel, testCase: .updated)
		
	}
	
	func testModelCanBeDeletedByAPI() throws {
		let createdModel = try T.create(model: getModel(), on: conn)
		var allModels = try app.getResponse(to: getURI(), decodeTo: [T].self)
		XCTAssertTrue(allModels.count == 1)
		_ = try app.getResponse(
			to: "\(getURI())\(createdModel.id!)",
			method: .DELETE,
			headers: ["Content-Type": "application/json"],
			data: createdModel,
			decodeTo: T.self)
		allModels = try app.getResponse(to: getURI(), decodeTo: [T].self)
		XCTAssertTrue(allModels.count == 0)
	}
	
}
