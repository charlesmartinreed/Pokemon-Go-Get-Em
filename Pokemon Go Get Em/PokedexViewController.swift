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
    
    //MARK:- Properties
    var caughtPokemon = [Pokemon]()
    var uncaughtPokemon = [Pokemon]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        caughtPokemon = getPokemonForPokedex(caught: true)
        uncaughtPokemon = getPokemonForPokedex(caught: false)
        
        //table view setup methods
        PokedexTableView.dataSource = self
        PokedexTableView.delegate = self
    }
    
    //MARK:- @IBActions
    @IBAction func cancelButtonTapped(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
}

//MARK:- Extension and conformation methods
extension PokedexViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return caughtPokemon.count
        } else {
            return uncaughtPokemon.count
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2  //one for caught, one for uncaught
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "CAUGHT"
        } else {
            return "NOT CAUGHT"
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //should show a picture of the pokemon and its name
        let cell = UITableViewCell()
        
        var pokemon: Pokemon
        if indexPath.section == 0 {
            pokemon = caughtPokemon[indexPath.row]
        } else {
            pokemon = uncaughtPokemon[indexPath.row]
            cell.imageView?.alpha = 0.3
        }
        
        cell.textLabel?.text = pokemon.name
        if let pokeImage = Bundle.main.path(forResource: pokemon.name, ofType: "png") {
            cell.imageView?.image = UIImage(contentsOfFile: pokeImage)
        }
        
        
        return cell
    }
    
    
}
