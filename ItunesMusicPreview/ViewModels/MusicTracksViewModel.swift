//
//  MusicTracksViewModel.swift
//  ItunesMusicPreview
//
//  Created by DAIXinming on 2018/7/8.
//  Copyright © 2018 Xinming DAI. All rights reserved.
//

import UIKit
import SwiftyJSON

class MusicTracksViewModel: NSObject {

    typealias RequestMusicTracksCompletionBlock = (_ success: Bool, _ error: Error?) -> Void
    
    private var sharedCache: Cache {return Cache.shared }
    
    private lazy var searchHistoriesViewModel = SearchHistoriesViewModel()
    
    private var musicTracks: [MusicTrackItem] {
        get { return sharedCache.searchMusicTracks }
        set { sharedCache.searchMusicTracks = newValue }
    }
    
    var keyword: String?
    
    func requestMusicTracksForKeyword(_ keyword: String, completionBlock: @escaping RequestMusicTracksCompletionBlock) {
        self.keyword = keyword
        if searchHistoriesViewModel.appendUniqueSearchHistory(keyword) {
            API.getItunesMusicForSearchKeyward(keyword, withCompletionHandler: { (dataResponse) in
                switch dataResponse.result {
                case .success(let response):
                    let json = JSON(response)
                    if let musicTracks = API.parseItunesMusicSearchJsonResponse(json) {
                        self.musicTracks = musicTracks
                    }
                    completionBlock(true, nil)
                    
                case .failure(let error):
                    completionBlock(false, error)
                }
            })
        } else {
            completionBlock(true, nil)
        }
    }
    
    func numberOfSections() -> Int {
        return 1
    }
    
    func numberOfItemsInSection(_ section: Int) -> Int {
        return musicTracks.count
    }
    
    func itemForIndexPath(_ indexPath: IndexPath) -> MusicTrackItem? {
        if musicTracks.indices.contains(indexPath.row) {
            return musicTracks[indexPath.row]
        } else {
            return nil
        }
    }
}
