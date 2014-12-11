//
//  ViewController.swift
//  SQLite.swift-sample
//
//  Created by bakaneko on 9/12/2014.
//  Copyright (c) 2014 nekonyan. All rights reserved.
//

import UIKit
import SQLite

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    var viewModels: [Model]?

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
        return Model.Storage.models.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell?
        cell = tableView.dequeueReusableCellWithIdentifier("TableViewCell") as? UITableViewCell
        if cell == nil {
            cell = UITableViewCell(style: .Default, reuseIdentifier: "TableViewCell")
        }

        if let model = modelAt(indexPath.row) {
            cell?.detailTextLabel?.text = "id: \(model.id), unique: \(model.unique)"
            cell?.textLabel?.text = model.name
        } else {
            cell?.detailTextLabel?.text = nil
            cell?.textLabel?.text = nil
        }

        return cell!
    }

    func updateViewModel() {
        let query = Model.Storage.models
        var array = [Model]()
        for row in query {
            let model = row.map() as Model
            array.append(model)
        }

        viewModels = array
    }

    func modelAt(index: Int) -> Model? {
        if viewModels == nil {
            updateViewModel()
        }

        return viewModels?[index]
    }

    func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {

    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("showDetail", sender: indexPath)
    }

    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }

    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            if let model = modelAt(indexPath.row) {
                if model.delete() > 0 {
                    viewModels?.removeAtIndex(indexPath.row)
                    tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
//                    updateViewModel()
//                    tableView.reloadData()
                }
            }
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            switch identifier {
            case "showDetail":
                if let indexPath = sender as? NSIndexPath {
                    let destination = segue.destinationViewController as DetailTableViewController
                    destination.parentModel = modelAt(indexPath.row)
                }
                break
            default:
                break
            }
        }
    }


    @IBAction func addButtonTapped(sender: AnyObject) {
        let count = Model.Storage.models.count
        for i in 0..<20 {
            let model = Model(name: NSUUID().UUIDString)
            model.unique = "unique \(count + i)"
            model.save()
        }

        updateViewModel()
        tableView.reloadData()
    }
}

