//
//  DataProvider.swift
//  TawkDemo
//
//  Created by Sanjay Thakkar on 04/03/21.
//

import Foundation
import CoreData

class DataProvider {

    private let persistentContainer: NSPersistentContainer
    private let repository: APIManager

    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }

    init(persistentContainer: NSPersistentContainer, repository: APIManager) {
        self.persistentContainer = persistentContainer
        self.repository = repository
    }

    func fetchUsers(fromId:Int, completion: @escaping(Error?) -> Void) {
        repository.getUsers(id: fromId) { userList, error in
            if let error = error {
                completion(error)
                return
            }

            guard let userList = userList else {
                completion(error)
                return
            }

            let taskContext = self.persistentContainer.newBackgroundContext()
            taskContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            taskContext.undoManager = nil

            _ = self.syncUsers(users: userList, taskContext: taskContext)

            completion(nil)
        }
    }
    func fetchUserDetails(userName:String, completion: @escaping (Error?)->Void)  {
        repository.getUserDetails(userName: userName) { (object, err) in
            if let error = err {
                completion(error)
                return
            }

            guard let userObject = object else {
                completion(err)
                return
            }
            let taskContext = self.persistentContainer.newBackgroundContext()
            taskContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            taskContext.undoManager = nil
           _ = self.syncProfile(profile: userObject, taskContext: taskContext)
            completion(nil)
        }
    }
    private func syncUsers(users: [ShortUserObject], taskContext: NSManagedObjectContext) -> Bool {
        var successfull = false
        let matchingUserRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Users")
        let userIds = users.map { $0.id }.compactMap { $0 }
        matchingUserRequest.predicate = NSPredicate(format: "id in %@", argumentArray: [userIds])
        let updatingUsers = try! taskContext.fetch(matchingUserRequest) as! [Users]
        taskContext.performAndWait {

            for userAPI in users {
                if let object = updatingUsers.first(where: { (obj) -> Bool in
                    return obj.id == userAPI.id
                }) {
                    try! object.update(with: userAPI)
                }
                else
                {
                    guard let user = NSEntityDescription.insertNewObject(forEntityName: "Users", into: taskContext) as? Users else {
                        print("Error: Failed to create a new Film object!")
                        return
                    }

                    do {
                        try user.update(with: userAPI)
                    } catch {
                        print("Error: \(error)\nThe User object will be deleted.")
                        taskContext.delete(user)
                    }
                }
            }

            // Save all the changes just made and reset the taskContext to free the cache.
            if taskContext.hasChanges {
                do {
                    try taskContext.save()
                } catch {
                    print("Error: \(error)\nCould not save Core Data context.")
                }
                taskContext.reset() // Reset the context to clean up the cache and low the memory footprint.
            }
            successfull = true
        }
        return successfull
    }
    
    private func syncProfile(profile: ProfileObject, taskContext: NSManagedObjectContext) -> Bool {
        var successfull = false
        let matchingUserRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Users")
        matchingUserRequest.predicate = NSPredicate(format: "id = %@", String(profile.id))
        var updatingUsers:[Users]!
        do {
            updatingUsers = try taskContext.fetch(matchingUserRequest) as? [Users]
        }
        catch
        {
            print(error)
        }
        
        taskContext.performAndWait {
        
             try! updatingUsers.first!.update(with: profile)
            // Save all the changes just made and reset the taskContext to free the cache.
            if taskContext.hasChanges {
                do {
                    try taskContext.save()
                } catch {
                    print("Error: \(error)\nCould not save Core Data context.")
                }
                taskContext.reset() // Reset the context to clean up the cache and low the memory footprint.
            }
            successfull = true
        
        }
        return successfull
    }
    func getUser(id:Int) -> Users? {
        let matchingUserRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Users")
        matchingUserRequest.predicate = NSPredicate(format: "id = %@", String(id))
        var updatingUsers:[Users]!
        do {
            updatingUsers = try viewContext.fetch(matchingUserRequest) as? [Users]
            return updatingUsers.first!
        }
        catch
        {
            print(error)
            return nil
        }
        
    }
    func removeAllData()
    {
        let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest<NSFetchRequestResult>(entityName: "Users")
        let objs = try! persistentContainer.viewContext.fetch(fetchRequest)
        for case let obj as NSManagedObject in objs {
            persistentContainer.viewContext.delete(obj)
        }
        
        try! persistentContainer.viewContext.save()
    }
    func fetchAll() -> [Users]
    {
        let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest<NSFetchRequestResult>(entityName: "Users")
        return try! persistentContainer.viewContext.fetch(fetchRequest) as! [Users]
    }
}
