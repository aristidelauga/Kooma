import XCTest
@testable import Kooma

final class UserManagerTests: XCTestCase {
    let testDefaults = UserDefaults(suiteName: "UserManagerTests")!
    let userKey = "currentUser"
    
    override func setUp() {
        super.setUp()
        testDefaults.removeObject(forKey: userKey)
    }
    
    override func tearDown() {
        testDefaults.removeObject(forKey: userKey)
        super.tearDown()
    }
    
    func testInit_noUserInDefaults_currentUserIsNil() {
        let manager = UserManager(userDefaults: testDefaults)
        XCTAssertNil(manager.currentUser)
    }
    
    func testInit_withSavedUser_loadsUser() {
        let user = UserUI(id: "id1", name: "Test")
        let data = try! JSONEncoder().encode(user)
        testDefaults.set(data, forKey: userKey)
        let manager = UserManager(userDefaults: testDefaults)
        XCTAssertEqual(manager.currentUser, user)
    }
    
    func testSetUser_setsCurrentUserAndSaves() {
        let manager = UserManager(userDefaults: testDefaults)
        let user = UserUI(id: "id2", name: "Alice")
        
        manager.setUser(user)
        XCTAssertEqual(manager.currentUser, user)

        let data = testDefaults.data(forKey: userKey)
        let loaded = try? JSONDecoder().decode(UserUI.self, from: data ?? Data())
        XCTAssertEqual(loaded, user)
    }
    
    func testSetUser_overwritesPreviousUser() {
        let manager = UserManager(userDefaults: testDefaults)
        let user1 = UserUI(id: "id1", name: "A")
        let user2 = UserUI(id: "id2", name: "B")
        manager.setUser(user1)
        manager.setUser(user2)
        XCTAssertEqual(manager.currentUser, user2)
    }
    
    func testSetUser_toNil_removesFromDefaults() {
        let manager = UserManager(userDefaults: testDefaults)
        let user = UserUI(id: "id3", name: "C")
        manager.setUser(user)
        manager.currentUser = nil
        XCTAssertNil(testDefaults.data(forKey: userKey))
    }
    
    func testInit_withCorruptedData_setsCurrentUserNil() {
        testDefaults.set(Data([0x00, 0x01, 0x02]), forKey: userKey)
        let manager = UserManager(userDefaults: testDefaults)
        XCTAssertNil(manager.currentUser)
    }
} 
