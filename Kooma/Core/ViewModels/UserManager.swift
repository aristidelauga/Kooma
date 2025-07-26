
import Foundation

@Observable
final class UserManager {
    private let userDefaults: UserDefaults
    var currentUser: UserUI? {
        didSet {
            self.saveUser()
        }
    }

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        self.loadUser()
    }

    func setUser(_ user: UserUI) {
        self.currentUser = user
    }

    private func saveUser() {
        guard let user = self.currentUser else {
            userDefaults.removeObject(forKey: "currentUser")
            return
        }

        if let data = try? JSONEncoder().encode(user) {
            userDefaults.set(data, forKey: "currentUser")
        }
    }

    private func loadUser() {
        if let data = userDefaults.data(forKey: "currentUser"),
           let user = try? JSONDecoder().decode(UserUI.self, from: data) {
            self.currentUser = user
        }
    }
}
