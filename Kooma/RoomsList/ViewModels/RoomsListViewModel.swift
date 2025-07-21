
import Foundation

@Observable @MainActor
final class RoomsListViewModel {
    var myRooms: [RoomUI] = []
    var joinedRooms: [RoomUI] = []
    
    private let service: any FirestoreServiceInterface
    private var myRoomsTask: Task<Void, Never>?
    private var joinedRoomsTask: Task<Void, Never>?
    
    
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

    func startListening(forUserID userID: String) {
        endListening()
        
        myRoomsTask = Task {
            do {
                for try await domainRooms in service.myRoomsStream(forUserID: userID) {
                    self.myRooms = domainRooms.map { $0.toUI() }
                }
            } catch {
                print("listenToMyRooms failed: \(error)")
            }
        }
        
        joinedRoomsTask = Task {
            do {
                for try await domainRooms in service.joinedRoomsStream(forUserID: userID) {
                    self.joinedRooms = domainRooms.map { $0.toUI() }
                }
            } catch {
                print("listenToJoinedRooms failed: \(error)")
            }
        }
    }
    
    func endListening() {
        myRoomsTask?.cancel()
        joinedRoomsTask?.cancel()
        myRoomsTask = nil
        joinedRoomsTask = nil
    }
    
}
