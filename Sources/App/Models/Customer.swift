//
//  Customer.swift
//  App
//
//  Created by Johan Thorell on 2019-10-17.
//

import Foundation
import Vapor
import FluentPostgreSQL

struct Customer: Codable {
	var id: UUID?
	var email: String
}

extension Customer: PostgreSQLUUIDModel {}
extension Customer: Content {}
extension Customer: Migration {}
extension Customer: Parameter {}
