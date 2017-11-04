import UIKit
import Alamofire
import AlamofireImage
import MapKit

class EventDetailController: UIViewController {
    @IBOutlet private weak var name: UILabel!
    @IBOutlet private weak var descriptionView: UITextView!
    @IBOutlet private weak var banner: UIImageView!
    @IBOutlet private weak var mapView: MKMapView!

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
                self.mapView.setRegion(region, animated: true)
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
                self.mapView.setRegion(region, animated: true)
            })
        }
    }
}
