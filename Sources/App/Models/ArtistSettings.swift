//
//  TattooSettings.swift
//  App
//
//  Created by Johan Thorell on 2019-10-15.
//

import Foundation

import Foundation
import Vapor
import FluentPostgreSQL

enum ArtistPropertySetting: Codable {
	
	case position([String])
	case image(data: File)
	case color(hasColor: Bool)
}
extension ArtistPropertySetting {

    private enum CodingKeys: String, CodingKey {
		case position
		case image
		case color
    }

    enum PostTypeCodingError: Error {
        case decoding(String)
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        if let value = try? values.decode([String].self, forKey: .position) {
			self = .position(value)
            return
        }
        if let value = try? values.decode(File.self, forKey: .image) {
			self = .image(data: value)
            return
        }
        if let value = try? values.decode(Bool.self, forKey: .color) {
			self = .color(hasColor: value)
            return
        }
        throw PostTypeCodingError.decoding("Whoops! \(dump(values))")
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
		case .position(let positions):
			try container.encode(positions, forKey: .position)
		case .image(let data):
			try container.encode(data, forKey: .image)
		case .color(let hasColor):
			try container.encode(hasColor, forKey: .color)
		}
    }
}
extension ArtistPropertySetting: Equatable {
	static func == (lhs: ArtistPropertySetting, rhs: ArtistPropertySetting) -> Bool {
		switch (lhs, rhs) {
		case (.color(let color1), .color(let color2)):
			return color1 == color2
		case (.position(let pos1), .position(let pos2)):
			return pos1 == pos2
		case (.image(let file1), .image(let file2)):
			return file1.data == file2.data
		default:
			return false
		}

	}
}

struct ArtistSettings: Codable {
	var id: UUID?
	var artistID: Artist.ID
	var settings: [ArtistPropertySetting]
}

extension ArtistSettings: PostgreSQLUUIDModel {}
extension ArtistSettings: Content {}
extension ArtistSettings: Migration {}
extension ArtistSettings: Parameter {}
