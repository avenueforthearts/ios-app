import UIKit
import Alamofire
import AlamofireImage

class EventListCell: UITableViewCell, NibReusable {
    static let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()

    @IBOutlet private weak var eventName: UILabel!
    @IBOutlet private weak var eventDescription: UILabel!
    @IBOutlet private weak var time: UILabel!
    @IBOutlet private weak var place: UILabel!
    @IBOutlet private weak var banner: UIImageView!

    @IBOutlet private weak var card: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.card.layer.shadowRadius = 4
        self.card.layer.shadowColor = UIColor.darkGray.cgColor
        self.card.layer.shadowOpacity = 1
        self.card.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.card.layer.shadowOpacity = 0.3
    }

    func setup(event: API.Models.Event) {
        if let link = event.cover {
            self.banner.af_setImage(withURL: link, placeholderImage: #imageLiteral(resourceName: "placeholder_image"))
        } else {
            self.banner.image = #imageLiteral(resourceName: "placeholder_image")
        }
        self.eventName.text = event.name
        self.eventDescription.text = event.description
        self.place.text = event.placeName
        self.time.text = EventListCell.formatter.string(from: event.startDate)
    }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        UIView.animate(withDuration: 0.2) {
            self.card.transform = highlighted ? CGAffineTransform(scaleX: 1.03, y: 1.03) : .identity
            self.card.layer.shadowRadius = highlighted ? 8 : 4
        }
    }
}
