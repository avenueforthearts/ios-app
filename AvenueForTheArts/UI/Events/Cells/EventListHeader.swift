//
//  EventListHeader.swift
//  AvenueForTheArts
//
//  Created by Chris Carr on 11/4/17.
// 

import UIKit

class EventListHeader: UITableViewHeaderFooterView, NibReusable {

    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var timeLabel: UILabel!

    func setup(date: String, time: String) {
        self.dateLabel.text = date
        self.timeLabel.text = time
    }
}
