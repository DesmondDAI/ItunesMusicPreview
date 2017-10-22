//
//  MusicTrackItem.swift
//  ItunesMusicPreview
//
//  Created by DAIXinming on 22/10/2017.
//  Copyright © 2017 Xinming DAI. All rights reserved.
//

import UIKit
import SwiftyJSON

class MusicTrackItem: NSObject {

    var trackID: Int!
    var artistID: Int!
    var collectionID: Int?
    var trackName: String!
    var artistName: String!
    var collectionName: String?
    var artworkUrl: String?
    var previewUrl: String?
    
    init?(json: JSON?) {
        guard let json = json else { return nil }
        trackID = json["trackId"].int!
        artistID = json["artistId"].int!
        collectionID = json["collectionId"].int
        trackName = json["trackName"].string!
        artistName = json["artistName"].string!
        collectionName = json["collectionName"].string
        artworkUrl = json["artworkUrl100"].string
        previewUrl = json["previewUrl"].string
    }
}
