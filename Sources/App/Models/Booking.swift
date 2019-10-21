//
//  TattooBooking.swift
//  App
//
//  Created by Johan Thorell on 2019-10-17.
//

import Foundation
import Vapor
import FluentPostgreSQL

enum BookingStatus: Codable {
	case initial(Bool) // Bool not really used, just for codable
	case requested(Date)
	case booked(Date)
}
extension BookingStatus {

    private enum CodingKeys: String, CodingKey {
		case initial
		case requested
		case booked
    }

    enum PostTypeCodingError: Error {
        case decoding(String)
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        if let value = try? values.decode(Bool.self, forKey: .initial) {
			self = .initial(value)
            return
        }
        if let value = try? values.decode(Date.self, forKey: .requested) {
			self = .requested(value)
            return
        }
        if let value = try? values.decode(Date.self, forKey: .booked) {
			self = .booked(value)
            return
        }
        throw PostTypeCodingError.decoding("Whoops! \(dump(values))")
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
		case .initial(let value):
			try container.encode(value, forKey: .initial)
		case .requested(let date):
			try container.encode(date, forKey: .requested)
		case .booked(let date):
			try container.encode(date, forKey: .booked)
		}
    }
}
struct Booking: Codable {

	var id: UUID?
	var pickedSettings: [ArtistPropertySetting]
	var state: BookingStatus
	var timeSlotID: Timeslot.ID?
	private(set) var artistID: Artist.ID
	private(set) var customerID: Customer.ID
}

extension Booking: PostgreSQLUUIDModel {}
extension Booking: Content {}
extension Booking: Migration {}
extension Booking: Parameter {}
