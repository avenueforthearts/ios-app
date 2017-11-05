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
        case error
    }

    private lazy var bag = DisposeBag()
    private lazy var loadingBag = DisposeBag()
    private let state = Variable<State>(.ready)
    @IBOutlet private weak var tableView: UITableView!

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

        self.tableView.register(cellType: LoadingCell.self)
        self.tableView.register(cellType: ErrorCell.self)
        self.tableView.register(cellType: EventListCell.self)
        self.tableView.register(headerFooterViewType: EventListHeader.self)

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
                    _self.tableView.refreshControl?.endRefreshing()
                case .error:
                    _self.tableView.refreshControl?.endRefreshing()
                }
            })
            .disposed(by: self.bag)
    }

    private func reloadContent(_ sender: Any? = nil) {
        if sender != nil {
            self.tableView.refreshControl?.beginRefreshing()
        }
        self.state.value = .ready
    }

    @IBAction private func reloadTriggered(_ sender: UIControl) {
        self.reloadContent()
    }
}

extension EventListController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch self.state.value {
        case .ready, .loading:
            return 0
        case .loaded(let eventGrouping):
            let events: [API.Models.Event]
            switch section {
            case 0:
                events = eventGrouping.today
            case 1:
                events = eventGrouping.tomorrow
            case 2:
                events = eventGrouping.upcoming
            default:
                events = []
            }

            return events.count
        case .error:
            return 1
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch self.state.value {
        case .ready:
            fatalError("Attempted to dequeue a cell while in the ready state")
        case .loading:
            fatalError("Attempted to dequeue a cell while in the loading state")
        case .loaded(let eventsGroup):
            let cell = tableView.dequeueReusableCell(for: indexPath) as EventListCell
            cell.setup(event: eventsGroup[indexPath]!)
            return cell
        case .error:
            let cell = tableView.dequeueReusableCell(for: indexPath) as ErrorCell
            cell.setup(
                message: NSLocalizedString("load_events_error", comment: ""),
                buttonTitle: NSLocalizedString("load_events_retry_title", comment: ""),
                retry: { [weak self] in
                    self?.reloadContent()
                }
            )
            return cell
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
