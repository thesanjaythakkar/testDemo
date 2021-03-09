//
//  APIManager.swift
//  TawkDemo
//
//  Created by Sanjay Thakkar on 04/03/21.
//

import Foundation



class ConcurrentOperation: Operation {

    typealias OperationCompletionHandler = (Data?,Error?)->()

    var completionHandler: OperationCompletionHandler?
    
    func complete(data:Data?, error:Error?)
    {
        completionHandler!(data,error)
    }

}
class APIManager:ConcurrentOperation {
    
    
    //static let shared = APIManager()
    private let url:URL!
     init(url:URL) {
        self.url = url
    }
    private let urlSession = URLSession.shared
    
    override func main()
    {
        urlSession.dataTask(with: url) { (data, response, error) in
            if let error = error {
                self.complete(data: nil, error: error)
                return
            }
            guard let data = data else {
                self.complete(data: nil, error: error)
                return
            }
            
            self.complete(data: data, error: nil)
        }.resume()
    }
   
    
}
class QueueManager {
    
    lazy var queue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        return queue;
    }()

    // MARK: - Singleton
    
    static let shared = QueueManager()
    
    // MARK: - Addition
    
    func enqueue(_ operation: Operation) {
        queue.addOperation(operation)
    }
}
class APIDataManager {
    
    private let queueManager = QueueManager.shared
    
    // MARK: - Init
    private let baseURL = "https://api.github.com/"
    
    static let shared = APIDataManager()
    
    // MARK: - Retrieval
    func getUsers(id:Int, completion: @escaping(_ users: [ShortUserObject]?,_ error: Error?) -> ()) {
        let usersURL = baseURL + "users?since=" + String(id)
        if !NetworkManager.shared.currentReachableStatus
        {
            completion([],nil)
        }
        else{
            let operation = APIManager.init(url: URL(string: usersURL)!)
            operation.completionHandler = { data, error in
                if let data = data
                {
                    completion(try! JSONDecoder().decode([ShortUserObject].self, from: data), nil)
                }
                else
                {
                    completion(nil, error)
                }
            }
            self.queueManager.enqueue(operation)
        }
       
    }
    func getUserDetails(userName:String, completion: @escaping (_ profile:ProfileObject?, _ error: Error?)-> ())
    {
        if !NetworkManager.shared.currentReachableStatus
        {
            completion(nil,nil)
        }
        else{
            let profileURL = baseURL + "users/" + userName
            
            let operation = APIManager.init(url: URL(string: profileURL)!)
            operation.completionHandler = { data, error in
                if let data = data
                {
                    completion(try! JSONDecoder().decode(ProfileObject.self, from: data), nil)
                }
                else
                {
                    completion(nil, error)
                }
            }
            self.queueManager.enqueue(operation)
        }
    }
}
