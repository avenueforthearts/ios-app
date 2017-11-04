//
//  TabBarController.swift
//  AvenueForTheArts
//
//  Created by Chris Carr on 11/4/17.
//  Copyright © 2017 MichiganLabs. All rights reserved.
//

import UIKit
import SafariServices

class TabBarController: UITabBarController {
    var previousTabItem = 0
    let MapControllerIndex = 1
    var googleMapsURL: URL?
    let MapURL = "https://www.google.com/maps/d/u/0/viewer?mid=1qx2B4eYIFcgWSOJKGsaKDoV0Z44&ll=42.96264625711024%2C-85.6686170667308&z=14"

    override func viewDidLoad() {
        self.delegate = self
        if let url = URL(string: MapURL) {
            self.googleMapsURL = url
        }
    }

    func returnToPreviousViewController() {
        self.selectedIndex = self.previousTabItem
    }
}

extension TabBarController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        print("Should Select has current Index: \(self.selectedIndex)")
        self.previousTabItem = self.selectedIndex
        return true
    }

    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        print("Selected item: \(self.selectedIndex)")
        if let url = self.googleMapsURL {
            // load the Safari View Controller!
            let web: SFSafariViewController
            if #available(iOS 11.0, *) {
                let config = SFSafariViewController.Configuration()
                config.barCollapsingEnabled = true
                config.entersReaderIfAvailable = false

                web = SFSafariViewController(url: url, configuration: config)
            } else {
                web = SFSafariViewController(url: url, entersReaderIfAvailable: false)
            }
            self.present(web, animated: true, completion: {
                self.returnToPreviousViewController()
            })
        }
    }
}

extension TabBarController: SFSafariViewControllerDelegate {
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        print("DONE button tapped")
    }
}
