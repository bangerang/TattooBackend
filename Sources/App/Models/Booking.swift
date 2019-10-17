//
//  TattooBooking.swift
//  App
//
//  Created by Johan Thorell on 2019-10-17.
//

import Foundation
import Vapor
import FluentPostgreSQL

struct Booking: Codable {
	var id: UUID?
	private(set) var pickedSettings: [ArtistPropertySetting]
	private(set) var artistID: Artist.ID
}

extension Booking: PostgreSQLUUIDModel {}
extension Booking: Content {}
extension Booking: Migration {}
extension Booking: Parameter {}
