import UIKit

class EventListCell: UITableViewCell, NibReusable {
    static let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()

    @IBOutlet private weak var eventName: UILabel!
    @IBOutlet private weak var eventDescription: UILabel!
    @IBOutlet private weak var startTime: UILabel!
    @IBOutlet private weak var endTime: UILabel!
    @IBOutlet private weak var place: UILabel!

    func setup(event: API.Models.Event) {
        self.eventName.text = event.name
        self.eventDescription.text = event.description
        self.place.text = event.place.name
        self.startTime.text = EventListCell.formatter.string(from: event.startDate)
        if let end = event.endDate {
            self.endTime.text = EventListCell.formatter.string(from: end)
            self.endTime.isHidden = false
        } else {
            self.endTime.isHidden = true
        }
    }
}
