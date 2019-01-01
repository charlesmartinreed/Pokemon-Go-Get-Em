//
//  PokedexViewController.swift
//  Pokemon Go Get Em
//
//  Created by Charles Martin Reed on 12/31/18.
//  Copyright © 2018 Charles Martin Reed. All rights reserved.
//

import UIKit

class PokedexViewController: UIViewController {

    //MARK:- @IBOutlets
    @IBOutlet weak var PokedexTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    //MARK:- @IBActions
    @IBAction func cancelButtonTapped(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
}
