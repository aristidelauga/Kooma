
import Foundation

@MainActor
@Observable final class CreateUserViewModel {
	var user: UserUI?
	var name: String = ""

	func createUser() {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else {
            return
        }
        self.user = UserUI(id: UUID().uuidString, name: trimmedName)
        guard let id = self.user?.id else {
            return
        }
        ActionEvent.sendAnalytics(event:  .createNewUser(userID: id))
	}
}
