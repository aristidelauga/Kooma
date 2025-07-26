

import Foundation

@MainActor
@Observable final class CreateUserViewModel {
	var user: UserUI?
	var name: String = ""

	func createUser() {
        guard !self.name.isEmpty else {
            return
        }
        self.user = UserUI(id: UUID().uuidString, name: name.trimmingCharacters(in: .whitespacesAndNewlines))
	}
}
