
import Foundation

@Observable @MainActor
final class ResearchRoomViewModel {
    private let service: any FirestoreServiceInterface
    
    var joinedRooms = [RoomUI]()
    
    init(service: any FirestoreServiceInterface = FirestoreService()) {
        self.service = service
    }
    
    private func getJoinedRoomsConverted() {
        self.joinedRooms = self.service.joinedRooms.map { $0.toUI() }
    }
    
    func joinRoom(code: String, user: UserUI) async throws {
        guard joinedRooms.contains(where: { $0.code == code }) == false else {
            throw JoinRoomError.alreadyJoined
        }
         do {
            try await self.service.joinRoom(withCode: code, user: user)
         } catch {
             throw JoinRoomError.unableToFindRoom
         }
    }
    
    func fetchJoinedRooms(userID: String) async throws {
        Task {
            try await self.service.fetchJoinedRooms(withUserID: userID)
            getJoinedRoomsConverted()
        }
    }
}
