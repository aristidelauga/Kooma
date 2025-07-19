
import Foundation

@Observable @MainActor
final class RoomsListViewModel {
    private let service: any FirestoreServiceInterface
    
    var myRooms: [RoomUI] = []
    var joinedRooms: [RoomUI] = []
    
    init(firestoreService: any FirestoreServiceInterface = FirestoreService()) {
        self.service = firestoreService
    }
    
    func addNewRoom(_ room: RoomUI) async {
        do {
            try await service.createRoom(room)
        } catch {
            print("Error preparing room for saving: \(error.localizedDescription)")
        }
    }
    
    func getMyRoomsConverted(userID: String) async throws {
        try await self.service.fetchMyRooms(withUserID: userID)
        self.myRooms = self.service.myRooms.map { $0.toUI() }
    }
    
    func getJoinedRoomsConverted(userID: String) async throws {
        try await self.service.fetchJoinedRooms(withUserID: userID)
        self.joinedRooms = self.service.joinedRooms.map { $0.toUI() }
    }
}
