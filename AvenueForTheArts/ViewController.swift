import UIKit
import RxSwift

class ViewController: UIViewController {
    enum State {
        case ready
        case loading
        case loaded([API.Models.Event])
        case error
    }

    private lazy var bag = DisposeBag()
    private lazy var loadingBag = DisposeBag()
    private let state = Variable<State>(.ready)
    @IBOutlet private weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.state
            .asObservable()
            .subscribe(onNext: { [weak self] state in
                guard let _self = self else { return }
                _self.tableView.reloadData()
                switch state {
                case .ready:
                    _self.state.value = .loading
                case .loading:
                    _self.loadingBag = DisposeBag()
                    EventStore.get()
                        .map { events -> State in return .loaded(events) }
                        .catchErrorJustReturn(.error)
                        .subscribe(
                            onNext: { state in
                                _self.state.value = state
                            }
                        )
                        .disposed(by: _self.loadingBag)
                case .loaded(_):
                    break
                case .error:
                    break
                }
            })
            .disposed(by: self.bag)
    }

    private func reloadContent() {
        self.state.value = .ready
    }

    @IBAction private func buttonPressed(_ sender: UIBarButtonItem) {
        self.reloadContent()
    }
}

extension ViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch self.state.value {
        case .ready:
            return 0
        case .loading:
            return 1
        case .loaded(let events):
            return events.count
        case .error:
            return 1
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch self.state.value {
        case .ready:
            fatalError("bro we ready")
        case .loading:
            let cell = UITableViewCell()
            cell.contentView.backgroundColor = .yellow
            return cell
        case .loaded(let events):
            let cell = UITableViewCell()
            cell.contentView.backgroundColor = .green
            return cell
        case .error:
            let cell = UITableViewCell()
            cell.contentView.backgroundColor = .red
            return cell
        }
    }
    
}

extension ViewController: UITableViewDelegate {

}
