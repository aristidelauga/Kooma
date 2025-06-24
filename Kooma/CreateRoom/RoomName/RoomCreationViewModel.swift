
import Foundation

@MainActor
@Observable final class RoomCreationViewModel {
	var room: RoomUI?
	var name: String = ""

	func createRoomWithName() async throws {
//		let room = try await CreateRoomUseCase().execute(name: name)
		do {
			try await self.room = RoomUI(id: UUID(), name: self.name)
		} catch {
			// TODO: create a real catch error condition
		}
	}
}
