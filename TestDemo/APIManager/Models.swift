//
//  ShortUserObject.swift
//  TawkDemo
//
//  Created by Sanjay Thakkar on 04/03/21.
//

import Foundation


struct ShortUserObject: Codable {
    let login: String
    let id: Int
    let nodeID, avatarURL, gravatarID, url: String
    let htmlURL, followersURL, followingURL, gistsURL: String
    let starredURL, subscriptionsURL, organizationsURL, reposURL: String
    let eventsURL, receivedEventsURL, type: String
    let siteAdmin: Bool

    enum CodingKeys: String, CodingKey {
        case login, id
        case nodeID = "node_id"
        case avatarURL = "avatar_url"
        case gravatarID = "gravatar_id"
        case url
        case htmlURL = "html_url"
        case followersURL = "followers_url"
        case followingURL = "following_url"
        case gistsURL = "gists_url"
        case starredURL = "starred_url"
        case subscriptionsURL = "subscriptions_url"
        case organizationsURL = "organizations_url"
        case reposURL = "repos_url"
        case eventsURL = "events_url"
        case receivedEventsURL = "received_events_url"
        case type
        case siteAdmin = "site_admin"
    }
}

struct ProfileObject: Codable {
    let login: String
    let id: Int
    let avatarURL, url: String?
    let siteAdmin: Bool
    let name, company: String?
    let blog: String?
    let followers, following: Int?
   

    enum CodingKeys: String, CodingKey {
        case login, id
        case avatarURL = "avatar_url"
        case url
        case siteAdmin = "site_admin"
        case name, company, blog
        case followers, following
    }
}

