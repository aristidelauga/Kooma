
import Foundation

@Observable @MainActor
final class RoomsListViewModel {
    private let firestoreService: any FirestoreServiceInterface
    
    var rooms: [RoomUI] { firestoreService.rooms }
    
    init(firestoreService: any FirestoreServiceInterface = FirestoreService()) {
        self.firestoreService = firestoreService
    }
    
    func fetchRooms() async throws {
        do {
            try await firestoreService.fetchRooms()
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
