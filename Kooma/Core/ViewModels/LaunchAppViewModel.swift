
import Foundation

@Observable @MainActor
final class LaunchAppViewModel {
    var myRooms: [RoomUI] = []
    var joinedRooms: [RoomUI] = []
    
    private let service: any FirestoreServiceInterface
    
    init(service: any FirestoreServiceInterface = FirestoreService()) {
        self.service = service
    }
    
    func getMyRoomsConverted(userID: String) async throws {
        try await self.service.fetchMyRooms(withUserID: userID)
        self.myRooms = self.service.myRooms.map { $0.toUI() }
    }
    
    func getJoinedRoomsConverted(userID: String) async throws {
        try await self.service.fetchJoinedRooms(withUserID: userID)
        self.joinedRooms = self.service.joinedRooms.map { $0.toUI() }
    }
    
    func startListening(forUserID userID: String) {
        service.startListening(forUserID: userID)
    }
    
    func endListening() {
        service.stopListening()
    }

}
