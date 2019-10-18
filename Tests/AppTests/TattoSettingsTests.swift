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
class TattoSettingsTests: ModelTests<ArtistSettings> {
	
	let testSettings: [ArtistPropertySetting] = [.color(hasColor: true)]

	lazy var artist: Artist = {
		return try! Artist.create(model: artistStub, on: conn)
	}()
	lazy var settingsMock: ArtistSettings = {
		return ArtistSettings(artistID: artist.id!, settings: settingsStub)
	}()
	override func getURI() -> String {
		return "/api/artists/settings/"
	}
	override func getModel() -> ArtistSettings {
		return settingsMock
	}
	
	override func didRecieveModel(_ model: ArtistSettings, testCase: TestCase) {
		switch testCase {
		case .saved:
			XCTAssertEqual(model.settings, settingsMock.settings)
			XCTAssertEqual(model.artistID, artist.id!)
			XCTAssertNotNil(model.id)
		case .retrieveOne:
			XCTAssertEqual(model.settings, settingsMock.settings)
			XCTAssertEqual(model.artistID, artist.id!)
			XCTAssertNotNil(model.id)
		case .updated:
			XCTAssertEqual(model.settings, testSettings)
		default:
			XCTFail()
		}
	}
	override func didRecieveModel(_ models: [ArtistSettings], testCase: TestCase) {
		switch testCase {
		case .retrieveAll:
			XCTAssert(models.count == 1)
			XCTAssert(models[0].artistID == artist.id!)
			XCTAssert(models[0].settings == settingsStub)
		default:
			XCTFail()
		}
	}
	override func willPerformUpdatenOn(_ model: ArtistSettings) -> ArtistSettings {
		var settingsToUpdate = model
		settingsToUpdate.settings = testSettings
		return settingsToUpdate
	}

}
