//
//  ViewController.swift
//  MemoryLeak
//
//  Created by Ronaldo II Dorado on 12/10/17.
//  Copyright © 2017 Ronaldo II Dorado. All rights reserved.
//

import UIKit

protocol PersonDelegate: class {}
protocol ApartmentDelegate: class {}

let LEAK_ON = true

class Car {
    let type: String
    weak var owner: Person?
   
    init(type: String) {
        self.type = type
    }
}

class Apartment {
    let address: String
    var owner: Person?
    weak var delegate: ApartmentDelegate?
    
    init(address: String) {
        self.address = address
    }
}

class Person {
    let name: String
    var apartment: Apartment?
    weak var delegate: PersonDelegate?
    
    init(name: String) {
        self.name = name
    }
}

class ViewController: UIViewController {
    
}

class CustomViewController: UIViewController, PersonDelegate, ApartmentDelegate {

    var person = Person(name:"John")
    var apartment = Apartment(address:"Sydney")
    var car = Car(type: "Toyota")
    var nonLeakingProperty = "Should not leak"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if LEAK_ON {
            makeLeakPersonAndApartment()
            makeLeakCarToPerson()
            makeLeakPersonDelegate()
            makeLeakApartmentDelegate()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func makeLeakPersonAndApartment() {
        person.apartment = apartment
        apartment.owner = person
    }
    
    func makeLeakCarToPerson() {
        car.owner = person
    }
    
    func makeLeakPersonDelegate() {
        person.delegate = self
    }
    
    func makeLeakApartmentDelegate() {
        apartment.delegate = self
    }

}

