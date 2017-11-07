import RxSwift

class EventListController: UIViewController {
    static let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d"
        return formatter
    }()

    enum State {
        case ready
        case loading
        case loaded(EventGrouping)
        case refreshing(EventGrouping)
        case error
    }

    private lazy var bag = DisposeBag()
    private lazy var loadingBag = DisposeBag()
    private let state = Variable<State>(.ready)
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var loadingView: UIView!
    @IBOutlet private weak var failMessage: UILabel!
    @IBOutlet private weak var retryButton: UIButton!
    @IBOutlet private weak var loadingStack: UIStackView!

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? EventDetailController, segue.identifier == "showEventDetail" {
            guard case .loaded(let events) = self.state.value,
                let cell = sender as? UITableViewCell,
                let indexPath = self.tableView.indexPath(for: cell)
            else { return }
            destination.event = events[indexPath]
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.register(cellType: EventListCell.self)
        self.tableView.register(headerFooterViewType: EventListHeader.self)
        let refresh = UIRefreshControl()
        refresh.addTarget(self, action: #selector(self.reloadTriggered(_:)), for: .valueChanged)
        self.tableView.refreshControl = refresh

        self.state
            .asObservable()
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] state in
                guard let _self = self else { return }
                _self.tableView.reloadData()
                switch state {
                case .ready:
                    _self.state.value = .loading
                case .loading:
                    _self.tableView.alpha = 0
                    _self.loadingStack.isHidden = false
                    _self.failMessage.isHidden = true
                    _self.retryButton.isHidden = true
                    fallthrough
                case .refreshing(_):
                    _self.loadingBag = DisposeBag()
                    EventStore.get()
                        .map { events -> State in return .loaded(events) }
                        .catchError { error -> Observable<State> in
                            return .just(.error)
                        }
                        .subscribe(
                            onNext: { [weak _self] state in
                                _self?.state.value = state
                            }
                        )
                        .disposed(by: _self.loadingBag)
                case .loaded(_):
                    self?.tableView.refreshControl?.endRefreshing()
                    UIView.animate(withDuration: 0.5, animations: {
                        _self.tableView.alpha = 1
                        _self.loadingStack.isHidden = false
                        _self.failMessage.isHidden = true
                        _self.retryButton.isHidden = true
                    })
                case .error:
                    _self.tableView.alpha = 0
                    _self.loadingStack.isHidden = true
                    _self.failMessage.isHidden = false
                    _self.retryButton.isHidden = false
                }
            })
            .disposed(by: self.bag)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.setNeedsStatusBarAppearanceUpdate()
    }

    private func reloadContent(_ sender: Any? = nil) {
        if sender is UIRefreshControl, case .loaded(let grouping) = self.state.value {
            self.state.value = .refreshing(grouping)
        } else {
            self.state.value = .ready
        }
    }

    @IBAction private func reloadTriggered(_ sender: UIControl) {
        self.reloadContent(sender)
    }
}

extension EventListController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch self.state.value {
        case .ready, .loading, .error:
            return 0
        case .loaded(let grouping), .refreshing(let grouping):
            let events: [API.Models.Event]
            switch section {
            case 0:
                events = grouping.today
            case 1:
                events = grouping.tomorrow
            case 2:
                events = grouping.upcoming
            default:
                events = []
            }

            return events.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch self.state.value {
        case .ready:
            fatalError("Attempted to dequeue a cell while in the ready state")
        case .loading:
            fatalError("Attempted to dequeue a cell while in the loading state")
        case .loaded(let grouping), .refreshing(let grouping):
            let cell = tableView.dequeueReusableCell(for: indexPath) as EventListCell
            cell.setup(event: grouping[indexPath]!, showDate: indexPath.section >= 2)
            return cell
        case .error:
            fatalError("Attempted to dequeue a cell while in the error state")
        }
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(EventListHeader.self)!
        let title: String
        let time: String
        if section == 0 {
            title = NSLocalizedString("Today", comment: "")
            time = EventListController.dayFormatter.string(from: Date())
        } else if section == 1 {
            title = NSLocalizedString("Tomorrow", comment: "")
            if let date = Calendar.current.date(byAdding: .day, value: 1, to: Date()) {
                time = EventListController.dayFormatter.string(from: date)
            } else {
                time = ""
            }

        } else {
            title = NSLocalizedString("Upcoming", comment: "")
            time = ""
        }

        header.setup(date: title, time: time)
        return header
    }
}

extension EventListController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let eventCell = self.tableView.cellForRow(at: indexPath) as? EventListCell {
            self.performSegue(withIdentifier: "showEventDetail", sender: eventCell)
        }
    }

    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
}
