//
//  MusicTableViewController.swift
//  ItunesMusicPreview
//
//  Created by DAIXinming on 22/10/2017.
//  Copyright © 2017 Xinming DAI. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import SwiftyJSON
import SVProgressHUD

class MusicTableViewController: UIViewController {
    
    @IBOutlet weak var emptyIndicatorLabel: UILabel!
    @IBOutlet weak var searchTextFieldContainerView: UIView!
    @IBOutlet weak var searchTextField: UITextField! {
        didSet {
            searchTextField.delegate = self
        }
    }
    
    @IBOutlet weak var searchCancelBtn: UIButton!
    @IBOutlet weak var searchingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var searchTableView: UITableView! {
        didSet {
            searchTableView.dataSource = self
            searchTableView.delegate = self
        }
    }
    
    var sharedCache: Cache {return Cache.shared }
    
    var searchHistories: [String] {
        get { return sharedCache.searchHistories }
        set { sharedCache.searchHistories = newValue }
    }
    
    var searchMusicTracks: [MusicTrackItem] {
        get { return sharedCache.searchMusicTracks }
        set { sharedCache.searchMusicTracks = newValue }
    }
    
    var tableDisplayType: MusicTableDisplayType = .empty {
        didSet {
            emptyIndicatorLabel.isHidden = tableDisplayType == .empty ? false : true
        }
    }
    var searchKeyword = ""  // For storing search keyword for recent tracks
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    // MARK: - Actions
    @IBAction func searchCancelBtnDidTap(_ sender: UIButton) {
        guard searchTextField.isFirstResponder else { return }
        searchTextField.resignFirstResponder()
        searchTextField.text = searchKeyword
    }
    
    
    // MARK: - Internal Methods
    func startSearchingAnimation() {
        searchCancelBtn.isHidden = true
        searchingIndicator.startAnimating()
    }
    
    func stopSearchingAnimation() {
        searchingIndicator.stopAnimating()
        searchCancelBtn.isHidden = false
    }
    
    func startSearchingForKeyword(_ keyword: String) {
        startSearchingAnimation()
        searchKeyword = searchTextField.text ?? ""
        API.getItunesMusicForSearchKeyward(keyword, withCompletionHandler: { (dataResponse) in
            self.stopSearchingAnimation()
            switch dataResponse.result {
            case .success(let response):
                let json = JSON(response)
                if let musicTracks = API.parseItunesMusicSearchJsonResponse(json) {
                    self.searchMusicTracks = musicTracks
                }
                self.searchTableView.reloadData()
                self.emptyIndicatorLabel.isHidden = self.searchMusicTracks.count == 0 ? false : true
                
            case .failure(let error):
                SVProgressHUD.showError(withStatus: error.localizedDescription)
            }
        })
    }
}


// MARK: - UITableViewDataSource
extension MusicTableViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchKeyword = textField.text ?? ""
        searchMusicTracks = [MusicTrackItem]()  // Clear previous search result
        searchTextField.resignFirstResponder()
        // Only append the one that is different from the latest record
        if let text = textField.text, searchHistories.last != text {
            searchHistories.insert(text, at: 0)  // Reverse order
            startSearchingForKeyword(text)
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        tableDisplayType = .history
        searchTableView.reloadData()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        tableDisplayType = .tracks
        searchTableView.reloadData()
    }
}


// MARK: - UITableViewDataSource
extension MusicTableViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch tableDisplayType {
        case .history:
            return searchHistories.count
            
        case .tracks:
            return searchMusicTracks.count
            
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch tableDisplayType {
        case .history:
            let historyCell = tableView.dequeueReusableCell(withIdentifier: Constants.tableViewCellID.searchHistory, for: indexPath) as! SearchHistoryTableViewCell
            let history = searchHistories[indexPath.row]
            historyCell.historyLabel.text = history
            return historyCell
            
        case .tracks:
            let trackCell = tableView.dequeueReusableCell(withIdentifier: Constants.tableViewCellID.searchResult, for: indexPath) as! SearchResultTableViewCell
            let trackItem = searchMusicTracks[indexPath.row]
            trackCell.loadMusicTrackItem(trackItem)
            return trackCell
            
        default:
            return UITableViewCell()
        }
    }
}


// MARK: - UITableViewDelegate
extension MusicTableViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch tableDisplayType {
        case .history:
            let selectedText = searchHistories[indexPath.row]
            searchTextField.resignFirstResponder()
            searchTextField.text = selectedText
            searchKeyword = selectedText
            if searchHistories.first != selectedText {  // Only append the one that is different from the previous one
                searchHistories.insert(selectedText, at: 0)
            }
            startSearchingForKeyword(selectedText)
            
        case .tracks:
            tableView.deselectRow(at: indexPath, animated: true)
            let selectedTrack = searchMusicTracks[indexPath.row]
            let playerVC = storyboard?.instantiateViewController(withIdentifier: Constants.viewControllerID.musicTrackPlayer) as! AVPlayerViewController
            if let trackURL = URL(string: selectedTrack.previewUrl ?? "") {
                playerVC.player = AVPlayer(url: trackURL)
                present(playerVC, animated: true, completion: {
                    playerVC.player?.play()  // Auto play
                })
            }
            
        default:
            break
        }
    }
}
