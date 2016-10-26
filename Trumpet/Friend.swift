//
//  Friend.swift
//  Trumpet
//
//  Created by Selim Halac on 5/10/16.
//  Copyright © 2016 Halac Technologies. All rights reserved.
//

import UIKit

class Friend: NSObject {
    var Name: String
    var Status: String
    var Username: String
    var Update: Bool
    
    init(FriendName: String, FriendStatus: String, FriendUser: String, UpdateUser: Bool) {
        Name = FriendName
        Status = FriendStatus
        Username = FriendUser
        Update = false
    }
}

class SearchItem: NSObject {
    var Name: String
    var Username: String
    init(SearchName: String, SearchUser: String) {
        Name = SearchName
        Username = SearchUser
    }
}

class User: NSObject{
    var Name: String?
    var Status: String?
    init(N: String, S: String) {
        Name = N;
        Status = S;
    }
}
