import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {
	let artistController = ArtistController(domain: ["artists"])
	try router.register(collection: artistController)
	
	let artistSettingsController = BaseController<ArtistSettings>(domain: ["artists", "settings"])
	try router.register(collection: artistSettingsController)
	
	let customerController = BaseController<Customer>(domain: ["customers"])
	try router.register(collection: customerController)
	
	let bookingsController = BaseController<Booking>(domain: ["artists", "bookings"])
	try router.register(collection: bookingsController)
}
