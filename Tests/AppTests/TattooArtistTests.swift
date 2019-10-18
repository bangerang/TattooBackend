//
//  TattooArtistTests.swift
//  AppTests
//
//  Created by Johan Thorell on 2019-10-16.
//

@testable import App
import Vapor
import XCTest
import FluentPostgreSQL

let artistStub = Artist(name: "Onur", username: "Onur2001", email: "onur@hotmail.com", password: "password")
let settingsStub: [ArtistPropertySetting] = [.position(["Elbow", "Arm", "Leg"]),
											 .size(["Big", "Small"]),
											 .color(hasColor: true),
											 .image(data: File(data: FileMock(),
															   filename: "Foo"))]

class TattooArtistTests: ModelTests<Artist> {
	
	override func getURI() -> String {
		return "/api/artists/"
	}
	override func getModel() -> Artist {
		return artistStub
	}
	
	override func didRecieveModel(_ model: Artist, testCase: TestCase) {
		switch testCase {
		case .saved:
			XCTAssertEqual(model.email, artistStub.email)
			XCTAssertEqual(model.username, artistStub.username)
			XCTAssertNotNil(model.id)
		case .retrieveOne:
			XCTAssertEqual(model.email, artistStub.email)
			XCTAssertEqual(model.username, artistStub.username)
			XCTAssertNotNil(model.id)
		case .updated:
			XCTAssertEqual(model.name, "Axel")
		default:
			XCTFail()
		}
	}
	
	override func didRecieveModel(_ models: [Artist], testCase: TestCase) {
		switch testCase {
		case .retrieveAll:
			XCTAssert(models.count == 1)
			XCTAssert(models[0].email == artistStub.email)
			XCTAssert(models[0].username == artistStub.username)
			XCTAssert(models[0].name == artistStub.name)
		default:
			XCTFail()
		}
	}
	
	override func willPerformUpdatenOn(_ model: Artist) -> Artist {
		var artistToChange = model
		artistToChange.name = "Axel"
		return artistToChange
	}
	
	func testGetSettingsFromArtist() throws {
		
		let artist = try Artist.create(model: artistStub, on: conn)
		let settingsWithoutID = ArtistSettings(artistID: artist.id!, settings: settingsStub)
		let settings = try ArtistSettings.create(model: settingsWithoutID, on: conn)
		
		let receivedSettings = try app.getResponse(to: "\(getURI())\(artist.id!)/settings", decodeTo: [ArtistSettings].self)

		XCTAssertEqual(receivedSettings[0].settings, settings.settings)
		XCTAssertEqual(receivedSettings[0].artistID, settings.artistID)
		XCTAssertNotNil(receivedSettings[0].id)
	}
	
}
