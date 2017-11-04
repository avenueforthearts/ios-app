import UIKit

class LoadingCell: UITableViewCell, NibReusable {
    @IBOutlet private weak var spinner: UIActivityIndicatorView!
    @IBOutlet private weak var label: UILabel!
}
