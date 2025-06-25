

import Foundation

@MainActor
@Observable final class CreateUserViewModel {
	var user: UserUI?
	var name: String = ""

	func createUser()  {
		self.user = UserUI(id: UUID(), name: name)
	}
}
