import UIKit
import Alamofire
import AlamofireImage

class EventDetailController: UIViewController {
    @IBOutlet private weak var name: UILabel!
    @IBOutlet private weak var descriptionView: UITextView!
    @IBOutlet private weak var banner: UIImageView!

    var event: API.Models.Event!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.name.text = self.event.name
        self.descriptionView.text = self.event.description
        if let string = self.event.cover?.source, let url = URL(string: string) {
            self.banner.isHidden = false
            self.banner.af_setImage(withURL: url)
        } else {
            self.banner.isHidden = true
        }
    }
}
