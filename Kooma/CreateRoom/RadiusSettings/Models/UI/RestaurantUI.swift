

import Foundation

struct RestaurantUI: Identifiable, Sendable, Codable {
	let id: String
	let name: String
	let phoneNumber: String
	let address: String
	let url: String
}
