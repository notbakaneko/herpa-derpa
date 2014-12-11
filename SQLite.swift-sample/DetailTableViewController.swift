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

    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }

    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            if let model = modelAt(indexPath.row) {
                if model.delete() > 0 {
                    parentModel?._details = nil // quick hack to force model to reload children
                    tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
                }
            }
        }
    }


    func modelAt(index: Int) -> DetailModel? {
        return parentModel?.details[index]
    }
}
