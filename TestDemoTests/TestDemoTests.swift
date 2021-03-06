//
//  TestDemoTests.swift
//  TestDemoTests
//
//  Created by Sanjay Thakkar on 06/03/21.
//

import XCTest
import CoreData

@testable import TestDemo

class TestDemoTests: XCTestCase {

    var dataProvider: DataProvider?

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        dataProvider = DataProvider(persistentContainer: CoreDataStack.shared.persistentContainer, repository: APIManager.shared)
        // In UI tests it is usually best to stop immediately when a failure occurs.


        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    func test_fetch_all_users()
    {

        dataProvider!.fetchUsers(fromId: 0) { (err) in
            if let err = err
            {
                XCTAssertThrowsError(err)
            }
            else
            {
                let users = self.dataProvider!.fetchAll()
                XCTAssertEqual(users.count, 30)
            }
        }
    }
    func test_fetch_user_details()
    {
        dataProvider!.fetchUserDetails(userName: "mojombo") { (err) in
            if let err = err
            {
                XCTAssertThrowsError(err)
            }
            else
            {
                if let user = self.dataProvider!.getUser(id: 0)
                {
                    XCTAssertEqual(user.login, "mojombo")
                }
            }
        }
    }
    func test_update_user()
    {
        let users = self.dataProvider!.fetchAll()
        let user = users[0]
        user.note = "Added by Sanjay"
        try! self.dataProvider!.viewContext.save()
        let again = self.dataProvider!.fetchAll()
        let againUsr = again[0]
        XCTAssertEqual(againUsr.note, "Added by Sanjay")
    }
    func test_numberofitems() {

        XCTAssertTrue(dataProvider!.fetchAll().count == 30, "Data is here")
    }

    func test_removeData()
    {
        dataProvider!.removeAllData()
        let users = self.dataProvider!.fetchAll()
        XCTAssertEqual(users.count, 0)
    }





}
