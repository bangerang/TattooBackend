//
//  TattoSize.swift
//  App
//
//  Created by Johan Thorell on 2019-10-22.
//

import Foundation
import Vapor
import FluentPostgreSQL

struct TattooSize: Codable {
	var id: UUID?
	private(set) var timeslotID: Timeslot.ID
	private(set) var artistID: Artist.ID
	private(set) var title: String // Could be a preset? Enum?
}

extension TattooSize: PostgreSQLUUIDModel {}
extension TattooSize: Content {}
extension TattooSize: Migration {}
extension TattooSize: Parameter {}
