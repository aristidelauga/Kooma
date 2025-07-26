import XCTest
@testable import Kooma

@MainActor
final class YourNextRoomViewModelTests: XCTestCase {
    var viewModel: YourNextRoomViewModel!
    var user: UserUI!
    
    override func setUp() {
        super.setUp()
        user = FixturesConstants.sampleUserUI1
        viewModel = YourNextRoomViewModel(user: user)
    }
    
    override func tearDown() {
        viewModel = nil
        user = FixturesConstants.sampleUserUI1
        super.tearDown()
    }
    
    func test_user_is_set() {
        user = FixturesConstants.sampleUserUI2
        viewModel = YourNextRoomViewModel(user: user)
        
        XCTAssertEqual(viewModel.user, user)
    }
    
    func test_createRoomWithName_success() {
        let owner = FixturesConstants.sampleUserUI1
        viewModel.createRoomWithName(with: owner)
        
        guard let room = viewModel.room else {
            XCTFail("Fail to create the room")
            return
        }
        
        XCTAssertEqual(room.administrator, owner)
        XCTAssertEqual(room.members.first, owner)
        
    }
    
}
