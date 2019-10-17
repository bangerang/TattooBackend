import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {
	let tattooArtistController = TattooArtistController()
	try router.register(collection: tattooArtistController)
	
	
	let tattooArtistSettingsController = TattooSettingsController()
	try router.register(collection: tattooArtistSettingsController)
}
