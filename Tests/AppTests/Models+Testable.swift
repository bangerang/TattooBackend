//
//  Models+Testable.swift
//  AppTests
//
//  Created by Johan Thorell on 2019-10-15.
//

@testable import App
import FluentPostgreSQL

extension Artist {
	static func create(artist: Artist, on connection: PostgreSQLConnection) throws -> Artist {
		let tattooArtist = Artist(name: artist.name, username: artist.username, email: artist.email, password: artist.password)
		return try tattooArtist.save(on: connection).wait()
	}
}
extension ArtistSettings {
	static func create(tattooArtistID: Artist.ID, settings: [ArtistPropertySetting] = [.position(["Elbow", "Hand", "Leg"])], on connection: PostgreSQLConnection) throws -> ArtistSettings {
		let setting = ArtistSettings(artistID: tattooArtistID, settings: settings)
		return try setting.save(on: connection).wait()
	}
//	init(tattooArtistID: TattooArtist.ID, settings: [Settings])
}
//extension User {
//  static func create(name: String = "Luke", username: String = "lukes",
//                     on connection: PostgreSQLConnection) throws -> User {
//    let user = User(name: name, username: username)
//    return try user.save(on: connection).wait()
//  }
//}
//extension Acronym {
//  static func create(short: String = "TIL",
//                     long: String = "Today I Learned",
//                     user: User? = nil,
//                     on connection: PostgreSQLConnection) throws -> Acronym {
//    var acronymsUser = user
//
//    if acronymsUser == nil {
//      acronymsUser = try User.create(on: connection)
//    }
//
//    let acronym = Acronym(short: short, long: long, userID: acronymsUser!.id!)
//    return try acronym.save(on: connection).wait()
//  }
//}

