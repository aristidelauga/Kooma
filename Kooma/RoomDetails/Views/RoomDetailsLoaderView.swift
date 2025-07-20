
import SwiftUI

struct RoomDetailsLoaderView: View {
    let roomID: String
    let user: UserUI
    var service: FirestoreService
    let navigationVM: NavigationViewModel
    
    @State private var room: RoomUI?
    @State private var isLoading: Bool = true
    
    var body: some View {
        Group {
            if let room = self.room {
                RoomDetailsView(
                    room: room,
                    user: self.user,
                    service: self.service,
                    navigation: self.navigationVM
                )
            } else if isLoading {
                ProgressView()
            } else {
                Text("Room not found")
            }
        }
        .onAppear {
            Task {
                do {
                    if let fetchedRoom = try await service.getRoomByID(roomID, userID: user.id) {
                        room = fetchedRoom.toUI()
                    }
                } catch {
                    navigationVM.path.removeLast()
                }
                isLoading = false
                guard let room = room  else {
                    return
                }
                print("room.votes: \(room.votes)")
            }
        }
    }
}

#Preview {
    RoomDetailsLoaderView(roomID: "rif", user: UserUI(id: "", name: ""), service: FirestoreService(), navigationVM: NavigationViewModel())
}
