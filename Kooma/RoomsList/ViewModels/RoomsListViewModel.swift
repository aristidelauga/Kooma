
import Foundation

@Observable @MainActor
final class RoomsListViewModel {
    private let firestoreService: any FirestoreServiceInterface
    
    var rooms: [RoomUI] { firestoreService.rooms }
    
    init(firestoreService: any FirestoreServiceInterface = FirestoreService()) {
        self.firestoreService = firestoreService
    }
    
    func fetchRooms(userID: String) async throws {
        do {
            try await firestoreService.fetchRooms(withUserID: userID)
        } catch {
            print("Failed to fetch rooms: \(error.localizedDescription)")
        }
    }
    
    func addNewRoom(_ room: RoomUI) async {
        do {
            try await firestoreService.createRoom(room)
        } catch {
            print("Error preparing room for saving: \(error.localizedDescription)")
        }
    }
}
