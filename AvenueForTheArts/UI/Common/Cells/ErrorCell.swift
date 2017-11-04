import UIKit

class ErrorCell: UITableViewCell, NibReusable {
    typealias RetryHandler = () -> Void

    @IBOutlet private weak var retryButton: UIButton!
    @IBOutlet private weak var message: UILabel!

    private var retryHandler: RetryHandler?

    func setup(message: String, buttonTitle title: String, retry handler: @escaping RetryHandler) {
        self.message.text = message
        self.retryButton.setTitle(title, for: .normal)
        self.retryHandler = handler
    }

    @IBAction private func retryButtonPressed(_ sender: UIButton) {
        self.retryHandler?()
    }
}
