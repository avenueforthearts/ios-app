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
        if let string = self.event.cover?.source, let url = URL(string: string) {
            self.banner.isHidden = false
            self.banner.af_setImage(withURL: url)
        } else {
            self.banner.isHidden = true
        }

        let span = MKCoordinateSpan(latitudeDelta: 0.015, longitudeDelta: 0.015)
        if let lat = self.event.place.location?.latitude, let long = self.event.place.location?.longitude {
            let location = CLLocation(latitude: Double(lat), longitude: Double(long))

            CLGeocoder().reverseGeocodeLocation(location, completionHandler: { (placemarks, error) in
                guard error == nil, let center = placemarks?.first?.location else {
                    self.mapView.isHidden = true
                    return
                }

                placemarks?.forEach {
                    self.mapView.addAnnotation(MKPlacemark(placemark: $0))
                }
                let region = MKCoordinateRegion(center: center.coordinate, span: span)
                self.mapView.setRegion(region, animated: false)
            })

        } else {
            CLGeocoder().geocodeAddressString(self.event.place.name, completionHandler: { (placemarks, error) in
                guard error == nil, let center = placemarks?.first?.location else {
                    self.mapView.isHidden = true
                    return
                }

                placemarks?.forEach {
                    self.mapView.addAnnotation(MKPlacemark(placemark: $0))
                }

                let region = MKCoordinateRegion(center: center.coordinate, span: span)
                self.mapView.setRegion(region, animated: false)
            })
        }
    }

    @available(iOS 11.0, *)
    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        self.statusBarMaskHeight.constant = self.view.safeAreaInsets.top
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
