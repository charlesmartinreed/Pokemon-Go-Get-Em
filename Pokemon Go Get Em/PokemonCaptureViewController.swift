//
//  PokemonCaptureViewController.swift
//  Pokemon Go Get Em
//
//  Created by Charles Martin Reed on 1/3/19.
//  Copyright © 2019 Charles Martin Reed. All rights reserved.
//

import UIKit

class PokemonCaptureViewController: UIViewController {

    //MARK:- Properties
    var pokemon: Pokemon!
    
    //MARK:- IBOutlets
    @IBOutlet weak var pokemonImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .green
        attemptToCapturePokemon(pokemon: pokemon)
        
    }
    
    func attemptToCapturePokemon(pokemon: Pokemon) {
        guard let pokeImage = Bundle.main.path(forResource: pokemon.name, ofType: "png") else { return }
        guard let pokemonName = pokemon.name else { return }
        
        pokemonImageView.image = UIImage(contentsOfFile: pokeImage)
        
        print("now attempting to capture \(pokemonName)")
        
        //if it hasn't short-circuited yet
    }
    
    func pokemonCaptureWasSuccessful() {
        
    }
    
    func pokemonCaptureFailed() {
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
