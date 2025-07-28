
import Foundation

@Observable @MainActor
final class LaunchAppViewModel {
    var myRooms: [RoomUI] = []
    var joinedRooms: [RoomUI] = []
    
    private let service: any FirestoreServiceInterface
    
    init(service: any FirestoreServiceInterface = FirestoreService()) {
        self.service = service
    }
    
    /// Gets all the rooms the user created. This is a punctual call to Firestore
    func getMyRoomsConverted(userID: String) async throws {
        try await self.service.fetchMyRooms(withUserID: userID)
        self.myRooms = self.service.myRooms.map { $0.toUI() }
    }
    
    /// Gets all the rooms the user joined. This is a punctual call to Firestore
    func getJoinedRoomsConverted(userID: String) async throws {
        try await self.service.fetchJoinedRooms(withUserID: userID)
        self.joinedRooms = self.service.joinedRooms.map { $0.toUI() }
    }
}
