//
//  AppsResponse.swift
//  SampleMVVM
//
//  Created by 古賀貴伍社用 on 2023/10/01.
//

import Foundation

struct AppsResponse: Codable {
    let feed: Feed
}

struct Feed: Codable {
    let results: [App]
}

public struct App: Codable {
    let artistName: String
    let id: String
    let name: String
    let releaseDate: String
    let artworkUrl100: String
    let url: String
}
