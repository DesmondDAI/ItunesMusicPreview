//
//  API.swift
//  ItunesMusicPreview
//
//  Created by DAIXinming on 22/10/2017.
//  Copyright © 2017 Xinming DAI. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import SwiftyJSON

class API {
    
    class func getItunesMusicForSearchKeyward(_ keyward: String, withCompletionHandler completionHandler: @escaping (DataResponse<Any>) -> Void) {
        Alamofire.request(String(format: "%@%@", Constants.itunesMusicHost, "search"), method: .get, parameters: ["term": keyward, "entity": ItunesReourcesEntityType.musicTrack.rawValue], encoding: URLEncoding.methodDependent, headers: nil).validate().responseJSON(completionHandler: completionHandler)
    }
    
    class func parseItunesMusicSearchJsonResponse(_ json: JSON) -> [MusicTrackItem]? {
        guard let results = json["results"].array else { return nil }
        var musicTracks = [MusicTrackItem]()
        for result in results {
            guard let musicTrack = MusicTrackItem.init(json: result) else { continue }
            musicTracks.append(musicTrack)
        }
        return musicTracks
    }
}
