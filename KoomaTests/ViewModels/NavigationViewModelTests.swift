import XCTest
@testable import Kooma
import SwiftUI

final class NavigationViewModelTests: XCTestCase {
    var navigationVM: NavigationViewModel!
    
    override func setUp() {
        super.setUp()
        navigationVM = NavigationViewModel()
    }
    
    override func tearDown() {
        navigationVM = nil
        super.tearDown()
    }
    
    func testShowRoomsListView_clearsAndAppendsRoomsList() {
        navigationVM.path.append(AppRoute.roomDetails(room: FixturesConstants.createSampleRoomUI()))
        navigationVM.showRoomsListView()
        
        let elements: [NavigationPath] = [navigationVM.path]
        
        XCTAssertEqual(elements.count, 1)
        XCTAssertTrue(elements.first.debugDescription.contains("roomsList"))
    }
    
    func testGoToOnboardingStepTwoView_appendsOnboardingStepTwo() {
        navigationVM.goToOnboardingStepTwoView()
        
        let elements: [NavigationPath] = [navigationVM.path]
        
        XCTAssertEqual(elements.count, 1)
        XCTAssertTrue(elements.first.debugDescription.contains("onboardingStepTwo"))
    }
    
    func testGoToCreateUserView_appendsCreateUserView() {
        navigationVM.goToCreateUserView()
        
        let elements: [NavigationPath] = [navigationVM.path]
        
        XCTAssertEqual(elements.count, 1)
        XCTAssertTrue(elements.first.debugDescription.contains("createUserView"))
    }
    
    func testGoToYourNextRoomViewFromUserCreation_appendsYourNextRoom() {
        navigationVM.goToYourNextRoomViewFromUserCreation(hasRooms: true)
        
        let elements: [NavigationPath] = [navigationVM.path]
        
        XCTAssertEqual(elements.count, 1)
        XCTAssertTrue(elements.first.debugDescription.contains("yourNextRoom(hasRooms: Optional(true)"))
    }
    
    func testGoToYourNextRoomView_clearsAndAppendsYourNextRoom() {
        navigationVM.path.append(AppRoute.createUserView)
        navigationVM.goToYourNextRoomView(hasRooms: false)
        
        let elements: [NavigationPath] = [navigationVM.path]
        
        XCTAssertEqual(elements.count, 1)
        XCTAssertTrue(elements.first.debugDescription.contains("yourNextRoom(hasRooms: Optional(false)"))
    }
    
    func testGoToSearchAddressView_appendsAddressSearch() {
        let room = FixturesConstants.createSampleRoomUI()
        
        navigationVM.goToSearchAddressView(withRoom: room)
        
        let elements: [NavigationPath] = [navigationVM.path]
        XCTAssertEqual(elements.count, 1)
        XCTAssertTrue(elements.first.debugDescription.contains("addressSearch"))
        XCTAssertTrue(elements.first.debugDescription.contains(room.administrator.id))
        XCTAssertTrue(elements.first.debugDescription.contains(room.administrator.name))
    }
    
    func testGoToRadiusSettingView_appendsRadiusSettingView() {
        let room = FixturesConstants.createSampleRoomUI()
        guard let address = room.address else {
            XCTFail()
            return
        }
        
        navigationVM.goToRadiusSettingView(withRoom: room)
        
        let elements: [NavigationPath] = [navigationVM.path]
        
        XCTAssertEqual(elements.count, 1)
        XCTAssertTrue(elements.first.debugDescription.contains("radiusSettingView"))
        XCTAssertTrue(elements.first.debugDescription.contains(room.administrator.id))
        XCTAssertTrue(elements.first.debugDescription.contains(room.administrator.name))
        XCTAssertTrue(elements.first.debugDescription.contains(address))
    }
    
    func testGoToResearchRoomView_appendsRoomSearch() {
        navigationVM.goToResearchRoomView(withRoomCode: "CODE123")
        
        let elements: [NavigationPath] = [navigationVM.path]
        
        XCTAssertEqual(elements.count, 1)
        XCTAssertTrue(elements.first.debugDescription.contains("RoomSearch"))
        XCTAssertTrue(elements.first.debugDescription.contains("CODE123"))
    }
    
    func testGoToRoomDetailsView_appendsRoomDetails() {
        let room = FixturesConstants.createSampleRoomUI()
        
        guard let name = room.name,
              let address = room.address else {
            XCTFail()
            return
        }
        
        navigationVM.goToRoomDetailsView(withRoom: room)
        
        let elements: [NavigationPath] = [navigationVM.path]
        
        XCTAssertEqual(elements.count, 1)
        XCTAssertTrue(elements.first.debugDescription.contains("roomDetails"))
        XCTAssertTrue(elements.first.debugDescription.contains(name))
        XCTAssertTrue(elements.first.debugDescription.contains(room.administrator.id))
        XCTAssertTrue(elements.first.debugDescription.contains(room.administrator.name))
        XCTAssertTrue(elements.first.debugDescription.contains(room.code))
        XCTAssertTrue(elements.first.debugDescription.contains(room.hostID))
        XCTAssertTrue(elements.first.debugDescription.contains(address))
    }
    
    func testGoToRestaurantDetailView_appendsRestaurantDetail() {
        let restaurant = FixturesConstants.sampleRestaurantUI1
        let names = ["Alice", "Bob"]
        
        navigationVM.goToRestaurantDetailView(withNames: names, andRestaurant: restaurant)
        
        let elements: [NavigationPath] = [navigationVM.path]
        
        XCTAssertTrue(elements.first.debugDescription.contains("restaurantDetail"))
        XCTAssertTrue(elements.first.debugDescription.contains(names.first!))
        XCTAssertTrue(elements.first.debugDescription.contains(names.last!))
        XCTAssertTrue(elements.first.debugDescription.contains(restaurant.id))
        XCTAssertTrue(elements.first.debugDescription.contains(restaurant.name))
        XCTAssertTrue(elements.first.debugDescription.contains(restaurant.phoneNumber))
        XCTAssertTrue(elements.first.debugDescription.contains(restaurant.address))
        XCTAssertTrue(elements.first.debugDescription.contains(restaurant.url))
    }
    
    func testGoToRoomDetailsViewFromRestaurantDetails_removesLast() {
        let room = FixturesConstants.createSampleRoomUI()
        let names = ["Alice", "Bob"]
        
        guard let restaurant = room.restaurants.first else {
            XCTFail()
            return
        }
        
        navigationVM.showRoomsListView()
        navigationVM.goToRoomDetailsView(withRoom: room)
        navigationVM.goToRestaurantDetailView(withNames: names, andRestaurant: restaurant)
        navigationVM.goToRoomDetailsViewFromRestaurantDetails()
        
        let elements: [NavigationPath] = [navigationVM.path]
                
        XCTAssertEqual(elements.count, 1)
        XCTAssertTrue(elements.first.debugDescription.contains("roomDetails"))
    }
    
    func testGoToRoomsListViewFromRoomDetails_removesLast() {
        navigationVM.path.append(AppRoute.roomDetails(room: FixturesConstants.createSampleRoomUI()))
        navigationVM.goToRoomsListViewFromRoomDetails()
        
        let elements: [NavigationPath] = [navigationVM.path]
        
        XCTAssertEqual(elements.count, 1)
    }
}

