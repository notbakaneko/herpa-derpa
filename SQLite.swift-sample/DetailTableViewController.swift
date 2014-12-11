//
//  DetailTableViewController.swift
//  SQLite.swift-sample
//
//  Created by bakaneko on 11/12/2014.
//  Copyright (c) 2014 nekonyan. All rights reserved.
//

import UIKit
import SQLite

class DetailTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    var parentModel: Model?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = parentModel?.details.count
        return count ?? 0
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell?
        cell = tableView.dequeueReusableCellWithIdentifier("DetailTableViewCell") as? UITableViewCell
        if cell == nil {
            cell = UITableViewCell(style: .Default, reuseIdentifier: "DetailTableViewCell")
        }

        if let model = modelAt(indexPath.row) {
            cell?.detailTextLabel?.text = "modelId: \(model.modelId)"
            cell?.textLabel?.text = "id: \(model.id)"
        } else {
            cell?.detailTextLabel?.text = nil
            cell?.textLabel?.text = nil
        }

        return cell!
    }

    func modelAt(index: Int) -> DetailModel? {
        return parentModel?.details[index]
    }
}
