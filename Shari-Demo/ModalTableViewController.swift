//
//  ModalTableViewController.swift
//  Shari
//
//  Created by nakajijapan on 2015/12/07.
//  Copyright © 2015 nakajijapan. All rights reserved.
//

import UIKit
import Shari

class ModalTableViewController: UITableViewController, Shari.NavigationControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let nc = self.navigationController as? Shari.NavigationController {
            nc.si_delegate = self
            nc.dismissControllSwipeDown = true
//            nc.fullScreenSwipeUp = false
        }
        self.tableView.isScrollEnabled = false
    }
    
    // MARK: - UITableViewDataSource

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel!.text = "Title #\((indexPath as NSIndexPath).row)"
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let currentNavigationController = self.navigationController as! Shari.NavigationController
        
        currentNavigationController.parentNavigationController!.si_dismissModalView({ () -> Void in
            print("close via cell")
        })

    }
    
    // MARK: - Button Actions
    
    @IBAction func closeButtonDidTap(_ sender: AnyObject) {
        
        let currentNavigationController = self.navigationController as! Shari.NavigationController
        currentNavigationController.parentNavigationController!.si_dismissModalView({ () -> Void in
            print("close via button")
        })
    }

    // MARK: - Shari.NavigationControllerDelegate

    func navigationControllerDidSpreadToEntire(_ navigationController: UINavigationController) {

        self.tableView.isScrollEnabled = true

        print("spread to the entire")

    }

    
}
