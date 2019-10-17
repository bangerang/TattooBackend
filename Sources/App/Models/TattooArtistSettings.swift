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

enum TattooPropertySetting: Codable {
	
	case position([String])
	case size([String])
	case image(data: File)
	case color(hasColor: Bool)
}
extension TattooPropertySetting {

    private enum CodingKeys: String, CodingKey {
		case position
		case size
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
        if let value = try? values.decode([String].self, forKey: .size) {
			self = .size(value)
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
		case .size(let sizes):
			try container.encode(sizes, forKey: .size)
		case .image(let data):
			try container.encode(data, forKey: .image)
		case .color(let hasColor):
			try container.encode(hasColor, forKey: .color)
		}
    }
}
extension TattooPropertySetting: Equatable {
	static func == (lhs: TattooPropertySetting, rhs: TattooPropertySetting) -> Bool {
		switch (lhs, rhs) {
		case (.color(let color1), .color(let color2)):
			return color1 == color2
		case (.position(let pos1), .position(let pos2)):
			return pos1 == pos2
		case (.size(let size1), .size(let size2)):
			return size1 == size2
		case (.image(let file1), .image(let file2)):
			return file1.data == file2.data
		default:
			return false
		}

	}
}

struct TattooArtistSettings: Codable {
	var id: UUID?
	var tattooArtistID: TattooArtist.ID
	var settings: [TattooPropertySetting]
}

extension TattooArtistSettings: PostgreSQLUUIDModel {}
extension TattooArtistSettings: Content {}
extension TattooArtistSettings: Migration {}
extension TattooArtistSettings: Parameter {}
