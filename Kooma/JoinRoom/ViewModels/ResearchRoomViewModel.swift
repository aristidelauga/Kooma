
import Foundation

@Observable @MainActor
final class ResearchRoomViewModel {
    private let service: any FirestoreServiceInterface
    
    var joinedRooms: [RoomUI] { self.service.joinedRooms }
    
    init(service: any FirestoreServiceInterface = FirestoreService()) {
        self.service = service
    }
    
    func joinRoom(code: String, user: UserUI) async throws {
//        try await self.fetchJoinedRooms(userID: user.id)
        guard joinedRooms.contains(where: { $0.code == code }) == false else {
            throw JoinRoomError.alreadyJoined
        }
         do {
            try await self.service.joinRoom(withCode: code, user: user)
         } catch {
             throw JoinRoomError.unableToFindRoom
         }
    }
    
//    private func fetchJoinedRooms(userID: String) async throws {
//        try await self.service.fetchJoinedRooms(withUserID: userID)
//    }
}
