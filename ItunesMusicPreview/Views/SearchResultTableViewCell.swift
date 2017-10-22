//
//  SearchResultTableViewCell.swift
//  ItunesMusicPreview
//
//  Created by DAIXinming on 22/10/2017.
//  Copyright © 2017 Xinming DAI. All rights reserved.
//

import UIKit
import SDWebImage

class SearchResultTableViewCell: UITableViewCell {

    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var trackNameLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var collectionNameLabel: UILabel!
    
    
    // MARK: - Api
    func loadMusicTrackItem(_ item: MusicTrackItem) {
        if let coverUrl = URL(string: item.artworkUrl ?? "") {
            coverImageView.sd_setImage(with: coverUrl, completed: nil)
        }
        trackNameLabel.text = item.trackName
        artistLabel.text = item.artistName
        collectionNameLabel.text = item.collectionName ?? "-"
    }

}
