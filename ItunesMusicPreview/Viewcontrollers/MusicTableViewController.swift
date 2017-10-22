//
//  MusicTableViewController.swift
//  ItunesMusicPreview
//
//  Created by DAIXinming on 22/10/2017.
//  Copyright © 2017 Xinming DAI. All rights reserved.
//

import UIKit
import SwiftyJSON

class MusicTableViewController: UIViewController {

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
        }
    }
    
    var searchHistories: [String] {
        get { return Cache.shared.searchHistories }
        set { Cache.shared.searchHistories = newValue }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    
    // MARK: - Actions
    @IBAction func searchCancelBtnDidTap(_ sender: UIButton) {
        searchTextField.resignFirstResponder()
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
}


// MARK: - UITableViewDataSource
extension MusicTableViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Only append the one that is different from the latest record
        if let text = textField.text, searchHistories.last != text {
            searchHistories.append(text)
            startSearchingAnimation()
            searchTableView.reloadData()
            API.getItunesMusicForSearchKeyward(text, withCompletionHandler: { (dataResponse) in
                self.stopSearchingAnimation()
                switch dataResponse.result {
                case .success(let response):
                    let json = JSON(response)
                    print("result: ", json)
                    
                case .failure(let error):
                    print("error: ", error.localizedDescription)
                }
            })
        }
        searchTextField.resignFirstResponder()
        return true
    }
}


// MARK: - UITableViewDataSource
extension MusicTableViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchHistories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let historyCell = tableView.dequeueReusableCell(withIdentifier: Constants.tableViewCellID.searchHistory, for: indexPath) as! SearchHistoryTableViewCell
        let reverseIndex = searchHistories.count - indexPath.row - 1  // Show latest record at the top
        let history = searchHistories[reverseIndex]
        historyCell.historyLabel.text = history
        return historyCell
    }
}
