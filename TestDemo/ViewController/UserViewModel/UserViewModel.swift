//
//  UserViewModel.swift
//  TestDemo
//
//  Created by Sanjay Thakkar on 22/02/22.
//

import UIKit
import Foundation

protocol RowViewModel {}

protocol CellConfigurable {
    func setup(viewModel: RowViewModel)
}

class UserViewModel: NSObject {
    
    var items = Observable<[Users]>(value: [])
    var filteredItems = Observable<[Users]>(value: [])
    override init() {
        
    }
}
