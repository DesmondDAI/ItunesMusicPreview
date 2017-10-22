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

class API {
    
    class func getItunesMusicForSearchKeyward(_ keyward: String, withCompletionHandler completionHandler: @escaping (DataResponse<Any>) -> Void) {
        Alamofire.request(String(format: "%@%@", Constants.itunesMusicHost, "search"), method: .get, parameters: ["term": keyward, "entity": ItunesReourcesEntityType.musicTrack.rawValue], encoding: URLEncoding.methodDependent, headers: nil).validate().responseJSON(completionHandler: completionHandler)
    }
}
