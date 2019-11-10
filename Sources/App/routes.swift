import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {
	
	let artistController = ArtistController(domain: ["artists"], httpMethods: [.get, .delete, .post, .put])
	try router.register(collection: artistController)
	
	let artistSettingsController = BaseModelController<ArtistSettings>(domain: ["artists", "settings"], httpMethods: [.get, .delete, .post, .put])
	try router.register(collection: artistSettingsController)
	
	let customerController = BaseModelController<Customer>(domain: ["customers"], httpMethods: [.get, .delete, .post, .put])
	try router.register(collection: customerController)
	
	let bookingsController = BookingController(domain: ["artists", "bookings"], httpMethods: [.get, .delete, .post, .put])
	try router.register(collection: bookingsController)
	
	let timeslotController = BaseModelController<Timeslot>(domain: ["artists", "timeslots"], httpMethods: [.get, .delete, .post, .put])
	try router.register(collection: timeslotController)
	
	let workplaceController = BaseModelController<Workplace>(domain: ["artists", "workplaces"], httpMethods: [.get, .delete, .post, .put])
	try router.register(collection: workplaceController)
	
	let workdayController = BaseModelController<WorkDay>(domain: ["artists", "workdays"], httpMethods: [.get, .delete, .post, .put])
	try router.register(collection: workdayController)
	
	let tattooSizesController = BaseModelController<TattooSize>(domain: ["artists", "tattoo-sizes"], httpMethods: [.get, .delete, .post, .put])
	try router.register(collection: tattooSizesController)
	
}
