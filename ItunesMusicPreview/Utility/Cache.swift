//
//  Cache.swift
//  ItunesMusicPreview
//
//  Created by DAIXinming on 22/10/2017.
//  Copyright © 2017 Xinming DAI. All rights reserved.
//

import UIKit

class Cache: NSObject {

    static let shared = Cache()
    
    lazy var searchHistories = [String]()
    lazy var searchMusicTracks = [MusicTrackItem]()
}
