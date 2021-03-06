//
//  Users+CoreDataProperties.swift
//  TestDemo
//
//  Created by Sanjay Thakkar on 05/03/21.
//
//

import Foundation
import CoreData


extension Users {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Users> {
        return NSFetchRequest<Users>(entityName: "Users")
    }

    @NSManaged public var avatar_url: String?
    @NSManaged public var blog: String?
    @NSManaged public var company: String?
    @NSManaged public var followers: Int64
    @NSManaged public var following: Int64
    @NSManaged public var id: Int64
    @NSManaged public var login: String?
    @NSManaged public var name: String?
    @NSManaged public var note: String?
    
    func update(with user: ShortUserObject) throws {

        self.login = user.login
        self.id = Int64(user.id)
        self.avatar_url = user.avatarURL
    }
    func update(with user: ProfileObject) throws {

        self.login = user.login
        self.id = Int64(user.id)
        self.avatar_url = user.avatarURL
        self.blog = user.blog
        self.company = user.company
        self.followers = Int64(user.followers ?? 0)
        self.following = Int64(user.following ?? 0)
        self.name = user.name
    }
}

extension Users : Identifiable {

}
