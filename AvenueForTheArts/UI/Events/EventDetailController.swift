import UIKit
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
    @IBOutlet private weak var statusBarMaskHeight: NSLayoutConstraint!
    @IBOutlet private weak var place: UILabel!
    @IBOutlet private weak var dates: UILabel!
    @IBOutlet private weak var mapButton: UIButton!

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
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self

        self.name.text = self.event.name
        self.descriptionView.text = self.event.description
        if let url = self.event.cover {
            self.banner.isHidden = false
            self.banner.af_setImage(withURL: url)
        } else {
            self.banner.isHidden = true
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

    @available(iOS 11.0, *)
    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        self.statusBarMaskHeight.constant = self.view.safeAreaInsets.top
    }
}

extension EventDetailController {
    @IBAction private func addCalendarPressed(_ sender: UIButton) {

    }

    @IBAction private func openFacebookPressed(_ sender: UIButton) {
        if let link = URL(string: "http://www.codingexplorer.com/") {
            UIApplication.shared.open(link)
        }
    }

    @IBAction private func sharePressed(_ sender: UIButton) {
        let title = "Swift is awesome!  Check out this website about it!"

        if let link = URL(string: "http://www.codingexplorer.com/") {
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
            self.bannerTop.constant = -0.2 * y
        }
    }
}
