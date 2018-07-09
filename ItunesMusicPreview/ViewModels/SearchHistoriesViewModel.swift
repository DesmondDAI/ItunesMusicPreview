//
//  SearchHistoriesViewModel.swift
//  ItunesMusicPreview
//
//  Created by DAIXinming on 2018/7/10.
//  Copyright © 2018 Xinming DAI. All rights reserved.
//

import UIKit

class SearchHistoriesViewModel: NSObject {
    
    private var sharedCache: Cache {return Cache.shared }
    
    private var searchHistories: [String] {
        get { return sharedCache.searchHistories }
        set { sharedCache.searchHistories = newValue }
    }
    
    func appendUniqueSearchHistory(_ history: String) -> Bool {
        if searchHistories.first != history {
            searchHistories.insert(history, at: 0) // Reverse order
            return true
        } else {
            return false
        }
    }
    
    func numberOfSections() -> Int {
        return 1
    }
    
    func numberOfItemsInSection(_ section: Int) -> Int {
        return searchHistories.count
    }
    
    func itemForIndexPath(_ indexPath: IndexPath) -> String? {
        if searchHistories.indices.contains(indexPath.row) {
            return searchHistories[indexPath.row]
        } else {
            return nil
        }
    }
}
