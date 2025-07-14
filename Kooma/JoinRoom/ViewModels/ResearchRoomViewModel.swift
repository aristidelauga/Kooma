
import Foundation

@Observable @MainActor
final class ResearchRoomViewModel {
    private let service: any FirestoreServiceInterface
    
    init(service: any FirestoreServiceInterface = FirestoreService()) {
        self.service = service
    }
    
    func joinRoom(code: String, user: UserUI) async throws {
        try await self.service.joinRoom(withCode: code, user: user)
    }
}
