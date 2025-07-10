
import Foundation

//@Observable @MainActor
//final class RoomsListViewModel {
//    var rooms: [RoomUI] = []
//    
//    private let firestoreService: any FirestoreServiceInterface
//    
//    init(service: FirestoreServiceInterface = FirestoreService()) {
//        self.firestoreService = service
//        self.loadRooms()
//    }
//
//    private func saveRoom(room: RoomUI) async throws {
//        let roomDTO = try await room.toDTO()
//        try await firestoreService.createRoom(roomDTO)
//    }
//    
//    private func loadRooms() {
//        Task {
//            do {
//                let roomDTOs = try await self.firestoreService.fetchRooms()
//                let rooms = try await withThrowingTaskGroup(of: RoomUI.self) { group in
//                    for dto in roomDTOs {
//                        group.addTask { try RoomUI(from: dto as! Decoder) }
//                    }
//                    var result: [RoomUI] = []
//                    for try await room in group {
//                        result.append(room)
//                    }
//                    return result
//                }
//                self.rooms = rooms
//            } catch {
//                // Handle error (e.g., log or show alert)
//                throw NSError(domain: "RoomUI", code: 2, userInfo: [NSLocalizedDescriptionKey: "No room to load"])
//            }
//        }
//    }
//    
//	func addNewRoom(_ room: RoomUI) {
//        let newRoom = room
//        self.rooms.append(newRoom)
//	}
//    
//}

@Observable @MainActor
final class RoomsListViewModel {
    private let firestoreService: FirestoreServiceInterface
    
    var rooms: [RoomUI] { firestoreService.rooms }
    
    init(firestoreService: FirestoreServiceInterface = FirestoreService()) {
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
