
import Foundation

@Observable @MainActor
final class RoomsListViewModel {
    private let firestoreService: any FirestoreServiceInterface
    
    var myRooms: [RoomUI] { firestoreService.myRooms }
    var joinedRooms: [RoomUI] { firestoreService.joinedRooms }
    
    init(firestoreService: any FirestoreServiceInterface = FirestoreService()) {
        self.firestoreService = firestoreService
    }
    
    func addNewRoom(_ room: RoomUI) async {
        do {
            try await firestoreService.createRoom(room)
        } catch {
            print("Error preparing room for saving: \(error.localizedDescription)")
        }
    }
}
