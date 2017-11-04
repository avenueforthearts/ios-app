//
//  MapController.swift
//  AvenueForTheArts
//
//  Created by Chris Carr on 11/4/17.
//  Copyright © 2017 MichiganLabs. All rights reserved.
//

import UIKit
import SafariServices

class MapController: UIViewController {

    var googleMapsURL: URL?
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var statusLabel: UILabel!

    override func viewDidLoad() {
        self.statusLabel.text = NSLocalizedString("Loading Google Map", comment: " ")

//        if let url = URL(string: "https://www.google.com/maps/d/u/0/viewer?mid=1qx2B4eYIFcgWSOJKGsaKDoV0Z44&ll=42.96264625711024%2C-85.6686170667308&z=14") {
//            self.googleMapsURL = url
//        }
    }
}
