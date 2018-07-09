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
    
    var musicTracksViewModel: MusicTracksViewModel!
    var searchHistoriesViewModel: SearchHistoriesViewModel!
    
    var tableDisplayType: MusicTracksModelType = .track
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewModels()
    }
    
    
    // MARK: - Actions
    @IBAction func searchCancelBtnDidTap(_ sender: UIButton) {
        searchTextField.resignFirstResponder()
        searchTextField.text = musicTracksViewModel.keyword
    }
    
    
    // MARK: - Internal Methods
    func setupViewModels() {
        musicTracksViewModel = MusicTracksViewModel()
        searchHistoriesViewModel = SearchHistoriesViewModel()
    }
    
    func startSearchingAnimation() {
        searchCancelBtn.isHidden = true
        searchingIndicator.startAnimating()
    }
    
    func stopSearchingAnimation() {
        searchCancelBtn.isHidden = false
        searchingIndicator.stopAnimating()
    }
    
    func startSearchingForKeyword(_ keyword: String?) {
        guard let keyword = keyword else { return }
        
        searchTextField.text = keyword
        emptyIndicatorLabel.isHidden = true
        startSearchingAnimation()
        
        self.musicTracksViewModel.requestMusicTracksForKeyword(keyword) { (success, error) in
            self.stopSearchingAnimation()
            if success {
                self.searchTableView.reloadData()
            } else if let error = error {
                SVProgressHUD.showError(withStatus: error.localizedDescription)
            }
        }
    }
}


// MARK: - UITableViewDelegate
extension MusicTableViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchTextField.resignFirstResponder()
        startSearchingForKeyword(textField.text)
        
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        tableDisplayType = .history
        searchTableView.reloadData()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        tableDisplayType = .track
        searchTableView.reloadData()
    }
}


// MARK: - UITableViewDataSource
extension MusicTableViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        switch tableDisplayType {
        case .history:
            return searchHistoriesViewModel.numberOfSections()
            
        case .track:
            return musicTracksViewModel.numberOfSections()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var rows = 0;
        
        switch tableDisplayType {
        case .history:
            rows = searchHistoriesViewModel.numberOfItemsInSection(section)
            
        case .track:
            rows = musicTracksViewModel.numberOfItemsInSection(section)
        }
        
        emptyIndicatorLabel.isHidden = (rows == 0) ? false : true
        
        return rows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch tableDisplayType {
        case .history:
            let historyCell = tableView.dequeueReusableCell(withIdentifier: Constants.tableViewCellID.searchHistory, for: indexPath) as! SearchHistoryTableViewCell
            let history = self.searchHistoriesViewModel.itemForIndexPath(indexPath)
            historyCell.historyLabel.text = history
            return historyCell
            
        case .track:
            let trackCell = tableView.dequeueReusableCell(withIdentifier: Constants.tableViewCellID.searchResult, for: indexPath) as! SearchResultTableViewCell
            let trackItem = self.musicTracksViewModel.itemForIndexPath(indexPath)
            trackCell.loadMusicTrackItem(trackItem)
            return trackCell
        }
    }
}


// MARK: - UITableViewDelegate
extension MusicTableViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch tableDisplayType {
        case .history:
            searchTextField.resignFirstResponder()
            if let selectedText = self.searchHistoriesViewModel.itemForIndexPath(indexPath) {
                startSearchingForKeyword(selectedText)
            }
            
        case .track:
            tableView.deselectRow(at: indexPath, animated: true)
            if let selectedTrack = self.musicTracksViewModel.itemForIndexPath(indexPath) {
                let playerVC = storyboard?.instantiateViewController(withIdentifier: Constants.viewControllerID.musicTrackPlayer) as! AVPlayerViewController
                if let trackURL = URL(string: selectedTrack.previewUrl ?? "") {
                    playerVC.player = AVPlayer(url: trackURL)
                    present(playerVC, animated: true, completion: {
                        playerVC.player?.play()  // Auto play
                    })
                }
            }
        }
    }
    
}
