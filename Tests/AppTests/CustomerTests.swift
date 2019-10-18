//
//  CustomerTests.swift
//  AppTests
//
//  Created by Johan Thorell on 2019-10-17.
//

@testable import App
import Vapor
import XCTest
import FluentPostgreSQL

let customerStub = Customer(email: "foo@hotmail.com")

class CustomerTests: ModelTests<Customer> {	
	
	override func getURI() -> String {
		return "/api/customers/"
	}
	override func getModel() -> Customer {
		return customerStub
	}
	override func didRecieveModel(_ model: Customer, testCase: TestCase) {
		switch testCase {
		case .saved:
			XCTAssertEqual(model.email, customerStub.email)
			XCTAssertNotNil(model.id)
		case .retrieveOne:
			XCTAssertEqual(model.email, customerStub.email)
			XCTAssertNotNil(model.id)
		case .updated:
			XCTAssertEqual(model.email, "bar@hotmail.com")
		default:
			XCTFail()
		}
	}
	override func didRecieveModel(_ models: [Customer], testCase: TestCase) {
		switch testCase {
		case .retrieveAll:
			XCTAssert(models.count == 1)
			XCTAssert(models[0].email == customerStub.email)
		default:
			XCTFail()
		}
	}
	override func willPerformUpdatenOn(_ model: Customer) -> Customer {
		var customerToUpdate = model
		customerToUpdate.email = "bar@hotmail.com"
		return customerToUpdate
	}
}
