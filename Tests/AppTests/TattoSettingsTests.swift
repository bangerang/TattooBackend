//
//  TattoSettingsTests.swift
//  AppTests
//
//  Created by Johan Thorell on 2019-10-15.
//

@testable import App
import Vapor
import XCTest
import FluentPostgreSQL

struct FileMock: LosslessDataConvertible {
	
	var someData: [UInt8] = [1,2,3,4,5]
	
	func convertToData() -> Data {
		return Data(bytes: someData)
	}
	
	static func convertFromData(_ data: Data) -> FileMock {
		return FileMock()
	}
	
	
}
class TattoSettingsTests: XCTestCase {

	var app: Application!
	var conn: PostgreSQLConnection!
	let settingsURI = "/api/artists/settings/"

	var artist: Artist!
	var settings: ArtistSettings!
	
	override func setUp() {
		try! Application.reset()
		app = try! Application.testable()
		conn = try! app.newConnection(to: .psql).wait()
		artist = try! Artist.create(model: artistStub, on: conn)
		settings = try! ArtistSettings.create(tattooArtistID: artist.id!, settings: settingsStub, on: conn)
	}
	override func tearDown() {
	  conn.close()
	  try? app.syncShutdownGracefully()
	}
	
	func testTattoArtistSettingsCanBeRetrievedByAPI() throws {
		
		let receivedSettings = try app.getResponse(to: settingsURI, decodeTo: [ArtistSettings].self)
		
		XCTAssert(receivedSettings.count == 1)
		XCTAssert(receivedSettings[0].artistID == artist.id!)
		XCTAssert(receivedSettings[0].settings == settingsStub)
		
	}

    func testTattooArtistSettingsCanBeSavedbyAPI() throws {
		
		let receivedSettings = try app.getResponse(
		  to: settingsURI,
		  method: .POST,
		  headers: ["Content-Type": "application/json"],
		  data: settings,
		  decodeTo: ArtistSettings.self)
		
		XCTAssertEqual(receivedSettings.settings, settings.settings)
		XCTAssertEqual(receivedSettings.artistID, settings.artistID)
		XCTAssertNotNil(receivedSettings.id)
		
		let allSettings = try app.getResponse(to: settingsURI, decodeTo: [ArtistSettings].self)
		
		XCTAssert(allSettings.count == 1)
		XCTAssert(allSettings[0].artistID == artist.id!)
		XCTAssert(allSettings[0].settings == settingsStub)
    }
	
	func testGettingASingleArtistSettingFromAPI() throws {
		
		let receivedSettings = try app.getResponse(to: "\(settingsURI)\(settings.id!)", decodeTo: ArtistSettings.self)
		
		XCTAssertEqual(receivedSettings.settings, settings.settings)
		XCTAssertEqual(receivedSettings.artistID, settings.artistID)
		XCTAssertNotNil(receivedSettings.id)
		
	}

}
