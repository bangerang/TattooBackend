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

let artistStub = TattooArtist(name: "Onur", username: "Onur2001", email: "onur@hotmail.com", password: "password")
let settingsStub: [TattooPropertySetting] = [.position(["Elbow", "Arm", "Leg"]),
											 .size(["Big", "Small"]),
											 .color(hasColor: true),
											 .image(data: File(data: FileMock(),
															   filename: "Foo"))]
class TattooArtistTests: XCTestCase {
	
	var app: Application!
	var conn: PostgreSQLConnection!
	let tattooURI = "/api/artists/"

	var artist: TattooArtist!
	var settings: TattooArtistSettings!
	
	override func setUp() {
		try! Application.reset()
		app = try! Application.testable()
		conn = try! app.newConnection(to: .psql).wait()
		artist = try! TattooArtist.create(artist: artistStub, on: conn)
		settings = try! TattooArtistSettings.create(tattooArtistID: artist.id!, settings: settingsStub, on: conn)
	}
	
	override func tearDown() {
		conn.close()
		try? app.syncShutdownGracefully()
	}
	
	func testTattoArtistCanBeRetrievedByAPI() throws {
		
		let receivedArtists = try app.getResponse(to: tattooURI, decodeTo: [TattooArtist].self)
		
		XCTAssert(receivedArtists.count == 1)
		XCTAssert(receivedArtists[0].email == artist.email)
		XCTAssert(receivedArtists[0].username == artist.username)
		XCTAssert(receivedArtists[0].name == artist.name)
		
	}

    func testTattooArtistCanBeSavedbyAPI() throws {
		
		let receivedArtist = try app.getResponse(
		  to: tattooURI,
		  method: .POST,
		  headers: ["Content-Type": "application/json"],
		  data: artist,
		  decodeTo: TattooArtist.self)
		
		XCTAssertEqual(receivedArtist.email, artist.email)
		XCTAssertEqual(receivedArtist.username, artist.username)
		XCTAssertNotNil(receivedArtist.id)
		
		let allArtists = try app.getResponse(to: tattooURI, decodeTo: [TattooArtist].self)
		
		XCTAssert(allArtists.count == 1)
		XCTAssert(allArtists[0].email == artist.email)
		XCTAssert(allArtists[0].username == artist.username)
		XCTAssert(allArtists[0].name == artist.name)
    }
	
	func testGettingASingleArtistSettingFromAPI() throws {
		
		let receivedArtist = try app.getResponse(to: "\(tattooURI)\(artist.id!)", decodeTo: TattooArtist.self)
		
		XCTAssertEqual(receivedArtist.email, artist.email)
		XCTAssertEqual(receivedArtist.username, artist.username)
		XCTAssertNotNil(receivedArtist.id)
		
	}
	
	func testGetSettingsFromArtist() throws {
		let receivedSettings = try app.getResponse(to: "\(tattooURI)\(artist.id!)/settings", decodeTo: [TattooArtistSettings].self)
		
		XCTAssertEqual(receivedSettings[0].settings, settings.settings)
		XCTAssertEqual(receivedSettings[0].tattooArtistID, settings.tattooArtistID)
		XCTAssertNotNil(receivedSettings[0].id)
	}
	
}
