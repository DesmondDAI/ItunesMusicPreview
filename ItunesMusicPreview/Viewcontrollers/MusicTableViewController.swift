//
//  MusicTableViewController.swift
//  ItunesMusicPreview
//
//  Created by DAIXinming on 22/10/2017.
//  Copyright © 2017 Xinming DAI. All rights reserved.
//

import UIKit

class MusicTableViewController: UIViewController {

    @IBOutlet weak var searchTextFieldContainerView: UIView!
    @IBOutlet weak var searchTextField: UITextField! {
        didSet {
            searchTextField.delegate = self
        }
    }
    
    @IBOutlet weak var searchCancelBtn: UIButton!
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
    
}


// MARK: - UITableViewDataSource
extension MusicTableViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Only append the one that is different from the latest record
        if let text = textField.text, searchHistories.last != text {
            searchHistories.append(text)
        }
        searchTableView.reloadData()
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
