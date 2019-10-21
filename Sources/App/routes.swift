import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {
	let artistController = ArtistController(domain: ["artists"])
	try router.register(collection: artistController)
	
	let artistSettingsController = BaseModelController<ArtistSettings>(domain: ["artists", "settings"])
	try router.register(collection: artistSettingsController)
	
	let customerController = BaseModelController<Customer>(domain: ["customers"])
	try router.register(collection: customerController)
	
	let bookingsController = BaseModelController<Booking>(domain: ["artists", "bookings"])
	try router.register(collection: bookingsController)
	
	let timeslotController = BaseModelController<Timeslot>(domain: ["artists", "timeslots"])
	try router.register(collection: timeslotController)
	
	let workplaceController = BaseModelController<Workplace>(domain: ["artists", "workplaces"])
	try router.register(collection: workplaceController)
}
