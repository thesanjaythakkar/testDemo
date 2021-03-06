//
//  APIManager.swift
//  TawkDemo
//
//  Created by Sanjay Thakkar on 04/03/21.
//

import Foundation

class APIManager {
    
    private init() {}
    static let shared = APIManager()
    
    private let urlSession = URLSession.shared
    private let baseURL = "https://api.github.com/"
    func callAPIFor<T:Decodable>(url:URL, responseType:T.Type, completion:@escaping(T?,Error?)->())
    {
        urlSession.dataTask(with: url) { (data, response, error) in
            if let error = error {
                completion(nil, error)
                return
            }
            guard let data = data else {
                completion(nil, error)
                return
            }
            do {
                completion(try JSONDecoder().decode(responseType.self, from: data), nil)
            } catch {
                completion(nil, error)
            }
        }.resume()
    }
    func getUsers(id:Int, completion: @escaping(_ users: [ShortUserObject]?,_ error: Error?) -> ()) {
        let usersURL = baseURL + "users?since=" + String(id)
        if !NetworkManager.shared.currentReachableStatus
        {
            completion([],nil)
        }
        else{
            callAPIFor(url: URL(string: usersURL)!, responseType: [ShortUserObject].self) { (response, err) in
                completion(response, err)
            }
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
            callAPIFor(url: URL(string: profileURL)!, responseType: ProfileObject.self) { (response, err) in
                completion(response, err)
            }
        }
        
    }
    
}
