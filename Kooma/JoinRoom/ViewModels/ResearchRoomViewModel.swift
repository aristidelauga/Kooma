
import Foundation

@Observable @MainActor
final class ResearchRoomViewModel {
    private let service: any FirestoreServiceInterface
    
    var joinedRooms = [RoomUI]()
    var myRooms = [RoomUI]()
    
    init(service: any FirestoreServiceInterface = FirestoreService()) {
        self.service = service
    }
    
    private func getJoinedRoomsConverted() {
        self.joinedRooms = self.service.joinedRooms.map { $0.toUI() }
    }
    
    private func getMyRoomsConverted() {
        self.myRooms = self.service.myRooms.map { $0.toUI() }
    }
    
    func joinRoom(code: String, user: UserUI) async throws {
        
        guard !joinedRooms.contains(where: { $0.code == code }) else {
            throw JoinRoomError.alreadyJoined
        }
        
        if myRooms.contains(where: { $0.code == code }) {
            throw JoinRoomError.administrator
        }
        
        do {
            try await self.service.joinRoom(withCode: code, user: user)
        } catch {
            throw JoinRoomError.unableToFindRoom
        }
    }
    
    func fetchJoinedRooms(userID: String) async throws {
        try await self.service.fetchJoinedRooms(withUserID: userID)
        self.getJoinedRoomsConverted()
    }
    
    func fetchMyRooms(userID: String) async throws {
        try await self.service.fetchMyRooms(withUserID: userID)
        self.getMyRoomsConverted()
    }
}
