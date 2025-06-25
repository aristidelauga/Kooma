
import Foundation

@Observable
final class UserManager {
	var currentUser: UserUI? {
		didSet {
			self.saveUser()
		}
	}

	init() {
		self.loadUser()
	}

	func setUser(_ user: UserUI) {
		self.currentUser = user
	}

	private func saveUser() {
		guard let user = self.currentUser else {
			UserDefaults.standard.removeObject(forKey: "currentUser")
			return
		}

		if let data = try? JSONEncoder().encode(user) {
			UserDefaults.standard.set(data, forKey: "currentUser")
		}
	}

	private func loadUser() {
		if let data = UserDefaults.standard.data(forKey: "currentUser"),
		   let user = try? JSONDecoder().decode(UserUI.self, from: data) {
			self.currentUser = user
		}
	}


}
