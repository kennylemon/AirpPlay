//
//  tableviewController.swift
//  AirPlay
//
//  Created by Kenny Lin on 2018/7/27.
//  Copyright © 2018 Kenny Lin. All rights reserved.
//

import UIKit
import AVFoundation

class tableviewController: UITableViewController {

    private lazy var dataSource: Dictionary<String, String> = {
        let item1 = "AirPlay playback"
        let item2 = "AirPlay2 playback - simple"
        var data: Dictionary<String, String> = ["0": item1, "1": item2]
        return data
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return dataSource.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = dataSource[String(indexPath.row)]
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let airplayvcid: String = dataSource[String(indexPath.row)]!
        let answer = airplayvcid.lowercased().contains("airplay2_")
        let answer2 = airplayvcid.lowercased().contains("airplay2")
        let viewcontrollerid = answer ? "airplay2_": (answer2 ? "airplay2" : "airplay" )
        let viewcontroller = storyboard?.instantiateViewController(withIdentifier: viewcontrollerid)
        self.navigationController?.pushViewController(viewcontroller!, animated: true)
    }
}
