import XCTest
@testable import Kooma

@MainActor
final class CreateUserViewModelTests: XCTestCase {
    
    var viewModel: CreateUserViewModel!
    
    override func setUp() {
        super.setUp()
        viewModel = CreateUserViewModel()
    }
    
    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }
    
    func testInit_createsInstanceWithDefaultValues() {
        let viewModel = CreateUserViewModel()
        
        XCTAssertNotNil(viewModel)
        XCTAssertNil(viewModel.user)
        XCTAssertEqual(viewModel.name, "")
    }
    
    func testNameProperty_canBeModified() {
        let newName = "Ross Geller"
        
        viewModel.name = newName
        
        XCTAssertEqual(viewModel.name, newName)
    }
    
    func testUserProperty_startsAsNil() {
        XCTAssertNil(viewModel.user)
    }
    
    func testCreateUser_withValidName_createsUser() {
        let userName = "Monica Geller"
        viewModel.name = userName
        
        viewModel.createUser()
        
        XCTAssertNotNil(viewModel.user)
        XCTAssertEqual(viewModel.user?.name, userName)
        XCTAssertNotNil(viewModel.user?.id)
        XCTAssertEqual(viewModel.user?.id.count, 36)
    }
    
    func testCreateUser_withEmptyName_doesNotCreateUser() {
        viewModel.name = ""
        
        viewModel.createUser()
        
        XCTAssertNil(viewModel.user)
    }
    
    func testCreateUser_withWhitespaceOnlyName_doesNotCreateUser() {
        viewModel.name = "   "
        
        viewModel.createUser()
        
        XCTAssertNil(viewModel.user)
    }
    
    func testCreateUser_trimsWhitespaceAndNewlines() {
        let nameWithWhitespace = "  Ross Geller  \n\t"
        viewModel.name = nameWithWhitespace
        
        viewModel.createUser()
        
        XCTAssertNotNil(viewModel.user)
        XCTAssertEqual(viewModel.user?.name, "Ross Geller")
    }
    
    func testCreateUser_generatesUniqueIDs() {
        let userName = "Test User"
        viewModel.name = userName
        
        viewModel.createUser()
        let firstUser = viewModel.user
        
        viewModel.createUser()
        let secondUser = viewModel.user
        
        XCTAssertNotNil(firstUser)
        XCTAssertNotNil(secondUser)
        XCTAssertNotEqual(firstUser?.id, secondUser?.id)
        XCTAssertEqual(firstUser?.name, secondUser?.name)
    }
    
    func testCreateUser_overwritesPreviousUser() {
        let firstName = "Monica"
        let secondName = "Ross"
        
        viewModel.name = firstName
        viewModel.createUser()
        let firstUser = viewModel.user
        
        viewModel.name = secondName
        viewModel.createUser()
        let secondUser = viewModel.user
        
        XCTAssertNotNil(firstUser)
        XCTAssertNotNil(secondUser)
        XCTAssertNotEqual(firstUser, secondUser)
        XCTAssertEqual(secondUser?.name, secondName)
    }
    
    func testCreateUser_withSpecialCharacters_createsUser() {
        let specialName = "José María O'Connor-Smith"
        viewModel.name = specialName
        
        viewModel.createUser()
        
        XCTAssertNotNil(viewModel.user)
        XCTAssertEqual(viewModel.user?.name, specialName)
    }
    
    func testCreateUser_withEmojis_createsUser() {
        let emojiName = "Monica 🎉 Ross 😊"
        viewModel.name = emojiName
        
        viewModel.createUser()
        
        XCTAssertNotNil(viewModel.user)
        XCTAssertEqual(viewModel.user?.name, emojiName)
    }
    
    func testCreateUser_withVeryLongName_createsUser() {
        let longName = String(repeating: "A", count: 1000)
        viewModel.name = longName
        
        viewModel.createUser()
        
        XCTAssertNotNil(viewModel.user)
        XCTAssertEqual(viewModel.user?.name, longName)
    }
    
    func testCreateUser_withSingleCharacter_createsUser() {
        let singleChar = "A"
        viewModel.name = singleChar
        
        viewModel.createUser()
        
        XCTAssertNotNil(viewModel.user)
        XCTAssertEqual(viewModel.user?.name, singleChar)
    }
    
    func testCreateUser_withNumbers_createsUser() {
        let numericName = "User123"
        viewModel.name = numericName
        
        viewModel.createUser()
        
        XCTAssertNotNil(viewModel.user)
        XCTAssertEqual(viewModel.user?.name, numericName)
    }

    func testCompleteFlow_nameInputThenCreateUser() {
        let userName = "Integration Test User"

        viewModel.name = userName
        XCTAssertEqual(viewModel.name, userName)
        XCTAssertNil(viewModel.user)
        
        viewModel.createUser()
        XCTAssertNotNil(viewModel.user)
        XCTAssertEqual(viewModel.user?.name, userName)
        XCTAssertNotNil(viewModel.user?.id)
    }
    
    func testCompleteFlow_multipleUserCreations() {
        let names = ["Monica", "Ross", "Chandler"]
        var createdUsers: [UserUI] = []
        
        for name in names {
            viewModel.name = name
            viewModel.createUser()
            
            XCTAssertNotNil(viewModel.user)
            XCTAssertEqual(viewModel.user?.name, name)
            createdUsers.append(viewModel.user!)
        }
        

        let userIds = createdUsers.map { $0.id }
        let uniqueIds = Set(userIds)
        XCTAssertEqual(userIds.count, uniqueIds.count)
    }
    
    func testCreateUser_withMixedWhitespace_trimsCorrectly() {
        let mixedWhitespace = "\n  \t  Ross Geller  \n  \t  "
        viewModel.name = mixedWhitespace
        
        viewModel.createUser()
        
        XCTAssertNotNil(viewModel.user)
        XCTAssertEqual(viewModel.user?.name, "Ross Geller")
    }
    
    func testCreateUser_withLeadingWhitespace_trimsCorrectly() {
        let leadingWhitespace = "   Ross Geller"
        viewModel.name = leadingWhitespace
        
        viewModel.createUser()
        
        XCTAssertNotNil(viewModel.user)
        XCTAssertEqual(viewModel.user?.name, "Ross Geller")
    }
    
    func testCreateUser_withTrailingWhitespace_trimsCorrectly() {
        let trailingWhitespace = "Ross Geller   "
        viewModel.name = trailingWhitespace
        
        viewModel.createUser()
        
        XCTAssertNotNil(viewModel.user)
        XCTAssertEqual(viewModel.user?.name, "Ross Geller")
    }
    
    func testCreateUser_preservesNameAfterCreation() {
        let userName = "Test User"
        viewModel.name = userName
        
        viewModel.createUser()
        
        XCTAssertEqual(viewModel.name, userName)
        XCTAssertNotNil(viewModel.user)
    }
    
    func testCreateUser_withEmptyName_preservesEmptyName() {
        viewModel.name = ""
        
        viewModel.createUser()
        
        XCTAssertEqual(viewModel.name, "")
        XCTAssertNil(viewModel.user)
    }
}
