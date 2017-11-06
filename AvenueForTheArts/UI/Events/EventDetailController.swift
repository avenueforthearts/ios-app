import UIKit
import RxSwift
import Alamofire
import AlamofireImage
import MapKit

class EventDetailController: UIViewController {

    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var name: UILabel!
    @IBOutlet private weak var descriptionView: UITextView!
    @IBOutlet private weak var banner: UIImageView!
    @IBOutlet private weak var mapView: MKMapView!
    @IBOutlet private weak var bannerTop: NSLayoutConstraint!
    @IBOutlet private weak var bannerAspect: NSLayoutConstraint!
    @IBOutlet private weak var statusBarMask: UIView!

    @IBOutlet private weak var navigationTitle: UILabel!
    @IBOutlet private weak var place: UILabel!
    @IBOutlet private weak var dates: UILabel!
    @IBOutlet private weak var mapButton: UIButton!

    private lazy var bag = DisposeBag()
    private let mapSpan = MKCoordinateSpan(latitudeDelta: 0.015, longitudeDelta: 0.015)
    private var mapItem: MKMapItem?
    private var placemark: MKPlacemark? {
        didSet {
            guard let placemark = self.placemark else { return }
            DispatchQueue.main.async {
                self.mapView.addAnnotation(placemark)
            }
        }
    }
    private var mapRegion: MKCoordinateRegion? {
        didSet {
            guard let region = self.mapRegion else { return }
            DispatchQueue.main.async {
                self.mapView.setRegion(region, animated: false)
            }
        }
    }

    var event: API.Models.Event!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.statusBarMask.alpha = 0
        self.statusBarMask.layer.shadowRadius = 4
        self.statusBarMask.layer.shadowColor = UIColor.darkGray.cgColor
        self.statusBarMask.layer.shadowOpacity = 1
        self.statusBarMask.layer.shadowOffset = CGSize(width: 0, height: 1)
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        self.dates.text = String(prettyDateRange: self.event)
        self.navigationTitle.text = self.event.name

        self.name.text = self.event.name
        self.descriptionView.text = self.event.description
        if let link = event.cover {
            self.banner.af_setImage(withURL: link, placeholderImage: #imageLiteral(resourceName: "placeholder_image"))
        } else {
            self.banner.image = #imageLiteral(resourceName: "placeholder_image")
        }

        self.place.text = self.event.placeName

        if let lat = self.event.latitude, let long = self.event.longitude {
            let location = CLLocation(latitude: lat, longitude: long)

            CLGeocoder().reverseGeocodeLocation(location, completionHandler: { (placemarks, error) in
                guard error == nil, let first = placemarks?.first, let center = first.location else {
                    self.placemark = MKPlacemark(coordinate: location.coordinate)
                    self.mapRegion = MKCoordinateRegion(center: location.coordinate, span: self.mapSpan)
                    return
                }

                self.placemark = MKPlacemark(placemark: first)
                self.mapRegion = MKCoordinateRegion(center: center.coordinate, span: self.mapSpan)
            })

        } else {
            CLGeocoder().geocodeAddressString(self.event.placeName, completionHandler: { (placemarks, error) in
                guard error == nil, let first = placemarks?.first, let center = first.location else {
                    self.mapButton.isHidden = true
                    return
                }

                self.placemark = MKPlacemark(placemark: first)
                self.mapRegion = MKCoordinateRegion(center: center.coordinate, span: self.mapSpan)
            })
        }
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.setNeedsStatusBarAppearanceUpdate()
    }
}

extension EventDetailController {
    @IBAction private func backPressed(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction private func addCalendarPressed(_ sender: UIButton) {
        CalendarStore
            .addToCalendar(self.event)
            .subscribe(
                onSuccess: { (status) in
                    let alert = UIAlertController(
                        title: NSLocalizedString("add_to_calendar_success_title", comment: ""),
                        message: String.localizedStringWithFormat(
                            NSLocalizedString("add_to_calendar_success_message", comment: ""),
                            self.event.name
                        ),
                        preferredStyle: .alert
                    )
                    let ok = UIAlertAction(
                        title: NSLocalizedString("OK", comment: ""),
                        style: .default,
                        handler: nil
                    )
                    alert.addAction(ok)
                    self.present(alert, animated: true, completion: nil)
                },
                onError: { error in
                    if error is CalendarStore.AddError {
                        let alert = UIAlertController(
                            title: NSLocalizedString("add_to_calendar_permission_title", comment: ""),
                            message: NSLocalizedString("add_to_calendar_permission_message", comment: ""),
                            preferredStyle: .alert
                        )
                        let ok = UIAlertAction(
                            title: NSLocalizedString("OK", comment: ""),
                            style: .default,
                            handler: nil
                        )
                        alert.addAction(ok)
                        self.present(alert, animated: true, completion: nil)
                    } else {
                        let alert = UIAlertController(
                            title: NSLocalizedString("add_to_calendar_error_title", comment: ""),
                            message: NSLocalizedString("add_to_calendar_error_message", comment: ""),
                            preferredStyle: .alert
                        )
                        let ok = UIAlertAction(
                            title: NSLocalizedString("OK", comment: ""),
                            style: .default,
                            handler: nil
                        )
                        alert.addAction(ok)
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            )
            .disposed(by: self.bag)
    }

    @IBAction private func openFacebookPressed(_ sender: UIButton) {
        if let link = self.event.link {
            UIApplication.shared.open(link)
        }
    }

    @IBAction private func sharePressed(_ sender: UIButton) {
        let title = String.localizedStringWithFormat(
            NSLocalizedString("event_share_format", comment: ""),
            self.event.name,
            self.event.placeName,
            String(prettyDateRange: self.event)
        )

        if let link = self.event.link {
            let activityVC = UIActivityViewController(activityItems: [title, link], applicationActivities: nil)
            activityVC.popoverPresentationController?.sourceView = sender
            self.present(activityVC, animated: true, completion: nil)
        }
    }

    @IBAction private func openInMapsPressed(_ sender: Any?) {
        guard let region = self.mapRegion, let place = self.placemark else { return }

        let options = [
            MKLaunchOptionsMapCenterKey: region.center as Any,
            MKLaunchOptionsMapSpanKey: region.span as Any,
            MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking as Any,
        ]

        let mapItem = MKMapItem(placemark: place)
        mapItem.name = self.event.name
        mapItem.openInMaps(launchOptions: options)
    }
}

extension EventDetailController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

extension EventDetailController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let y = scrollView.contentOffset.y
        let imageHeight = self.banner.frame.height
        self.statusBarMask.alpha = min(1, max(0, y / imageHeight))
        if y < 0 {
            self.bannerTop.constant = 0
            self.bannerAspect.constant = 1.5 * y
        } else {
            self.bannerAspect.constant = 0
            self.bannerTop.constant = -0.3 * y
        }
    }
}
