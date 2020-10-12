import UIKit
import MapKit
import Firebase

class MapEditViewController: UIViewController {
    
    var coordinate: CLLocationCoordinate2D?

    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var pinImageView: UIImageView!
    
    var documetID: String?
    
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        initImageView()
        
        if let c = coordinate {
            setMapRegion(c)
        }

    }
    
    func setMapRegion(_ coordinate: CLLocationCoordinate2D) {
        self.mapView.setCenter(coordinate, animated: true)
        var region:MKCoordinateRegion = self.mapView.region
        region.center = coordinate
        region.span.latitudeDelta = 0.0001
        region.span.longitudeDelta = 0.0001
        
        //設定した範囲をセットする
        self.mapView.setRegion(region, animated: true)
        
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
    
    @IBAction func finishButtonPressed(_ sender: UIBarButtonItem) {
        
        if let id = documetID {
            let c = mapView.centerCoordinate
            db.collection("advise").document(id).setData([
                                                            "coordinate" : GeoPoint(latitude: c.latitude, longitude: c.longitude)],
                                                         merge: true
            )
        }
        dismiss(animated: true)
    }
    

}
