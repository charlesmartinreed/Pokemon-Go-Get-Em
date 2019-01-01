//
//  CoreDataHelper.swift
//  Pokemon Go Get Em
//
//  Created by Charles Martin Reed on 12/31/18.
//  Copyright © 2018 Charles Martin Reed. All rights reserved.
//

import UIKit
import CoreData

//2. we need to be able to create Pokemon
func addAllPokemon() {
    createPokemon(name: "zubat")
    createPokemon(name: "snorlax")
    createPokemon(name: "abra")
    createPokemon(name: "eevee")
}

func createPokemon(name: String) {
    if let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
        
        let pokemon = Pokemon(context: context)
        // pokemon.hasBeenCaught is set to false by default
        guard let imageName = Bundle.main.path(forResource: name, ofType: "png") else { return }
        pokemon.imageName = imageName
        pokemon.name = name
        
        //save to Core Data
        try? context.save()
    }
}

//1. we want to be able to RETRIEVE Pokemon
func getAllPokemon() -> [Pokemon] {
    //check Core Data to see if we have any Pokemon at the moment
    //grab the persistent container, then the context
    if let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
        
        //attempt to fetch on the context
        if let pokemonData = try? context.fetch(Pokemon.fetchRequest()) as? [Pokemon] {
            if let allPokemon = pokemonData {
                //see if there's something in pokemon
                if allPokemon.isEmpty {
                    addAllPokemon()
                    return getAllPokemon()
                } else {
                    return allPokemon //array
                }
            }
        }
    }
    return [] //if this returns, shit went a little sideways.
}
