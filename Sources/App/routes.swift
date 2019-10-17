import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {
	let tattooArtistController = ArtistController()
	try router.register(collection: tattooArtistController)
	
	
	let tattooArtistSettingsController = ArtistSettingsController()
	try router.register(collection: tattooArtistSettingsController)
}
