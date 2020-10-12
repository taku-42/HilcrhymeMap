import UIKit
import MapKit
import FloatingPanel
import Firebase

class MapViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    var userLocation: CLLocationCoordinate2D?
    
    var locationManager: CLLocationManager!
    
    let searchViewController = SearchViewController()
    
    @IBOutlet weak var stackViewButton: UIStackView!
    
    @IBOutlet weak var pinImageView: UIImageView!
    
    @IBOutlet weak var noteLabel: UILabel!
    
    @IBOutlet weak var addButton: UIButton!
    
    var fpc = FloatingPanelController()
    
    let db = Firestore.firestore()
    
    let defaults = UserDefaults.standard
    
    var blockListArray: [String] = []
    
    var documentID: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        defaults.addObserver(self, forKeyPath: "BlockListArray", options: [NSKeyValueObservingOptions.new, NSKeyValueObservingOptions.old], context: nil)
        
        
        setUpView()
 
        setUpMapView(mapView.userLocation.coordinate)
        
        setUpAnnotation()
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        print(#function)
        if let blockLists = defaults.array(forKey: "BlockListArray") as? [String] {
            blockListArray = blockLists
        }
    }
    
    func setUpAnnotation() {
        db.collection("advise").addSnapshotListener { (querySnapshot, error) in
            if let e = error {
                print("There was an issue retrieving data from Firestore, \(e)")
            } else {
                if let snapshotDocuments = querySnapshot?.documents {
                    self.mapView.removeAnnotations(self.mapView.annotations)
                    for doc in snapshotDocuments {
                        let data = doc.data()
                        let pin = MyAnnotation()
                        if let coordinate = data["coordinate"] as? GeoPoint {
                            let c = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
                            pin.coordinate = c
                            pin.title = data["name"] as? String ?? ""
                            pin.subtitle = data["category"] as? String ?? ""
                            pin.documentID = doc.documentID
                            self.mapView.addAnnotation(pin)
                        }
                    }
                }
            }
        }
    }
    
    func setUpView() {
        addButton.layer.cornerRadius = 26
        
        noteLabel.isHidden = true
        
        noteLabel.layer.cornerRadius = 12
        
        stackViewButton.isHidden = true
        
        pinImageView.isHidden = true

        fpc.delegate = self
        
        fpc.surfaceView.cornerRadius = 24.0
    }
    
    @IBAction func searchButtonPressed(_ sender: UIButton) {
        
        performSegue(withIdentifier: "toSearchViewController", sender: nil)
    }

    @IBAction func addButtonPressed(_ sender: UIButton) {
        addButton.isHidden = true
        stackViewButton.isHidden = false
        pinImageView.isHidden = false
        noteLabel.isHidden = false
    }
    
    
    @IBAction func postButtonPressed(_ sender: UIButton) {
        addButton.isHidden = false
        stackViewButton.isHidden = true
        pinImageView.isHidden = true
        noteLabel.isHidden = true
//        performSegue(withIdentifier: "toPostViewController", sender: nil)
        performSegue(withIdentifier: "toNewRegistViewController", sender: nil)
    }
    
    @IBAction func postCalcelButtonPressed(_ sender: UIButton) {
        addButton.isHidden = false
        stackViewButton.isHidden = true
        pinImageView.isHidden = true
        noteLabel.isHidden = true
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toSearchViewController" {
            let vc = segue.destination as! SearchViewController
            vc.resultHandler = { coordinate in
                if let c = coordinate {
                    self.setUpMapView(c)
                }
            }
        } else if segue.identifier == "toNewRegistViewController" {
            let nc = segue.destination as! UINavigationController
            let vc = nc.topViewController as! NewRegistViewController
            vc.coordinate = mapView.centerCoordinate
            vc.resultHandler = { saving in
                if saving {
                    let pin = MKPointAnnotation()
                    pin.coordinate = self.mapView.centerCoordinate
                    self.mapView.addAnnotation(pin)
                } else {
                    return
                }
            }
        }
    }
    
    private func showBlockAlert(id: String) {
        let alert = UIAlertController(title: "このスポットはブロックされています", message: "ブロックを解除しますか？", preferredStyle: UIAlertController.Style.alert)
        
        let defaultAction = UIAlertAction(title: "はい", style: UIAlertAction.Style.default, handler: {
            (action: UIAlertAction!) -> Void in
            self.blockListArray.remove(value: id)
            self.defaults.set(self.blockListArray, forKey: "BlockListArray")
            self.defaults.synchronize()
            
        })
        
        let cancelAction = UIAlertAction(title: "いいえ", style: UIAlertAction.Style.default, handler: { (action: UIAlertAction!) -> Void in
        })
        
        alert.addAction(defaultAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
    }
}

//MARK: - MapView methods

extension MapViewController: MKMapViewDelegate {
    func setUpMapView(_ coordinate: CLLocationCoordinate2D) {
        
        mapView.delegate = self
        
        locationManager = CLLocationManager()
        
        locationManager.requestWhenInUseAuthorization()
        
        mapView.userTrackingMode = MKUserTrackingMode.follow
        
        let compass = MKCompassButton(mapView: mapView)
        
        compass.compassVisibility = .hidden
        
        //現在位置を中心にして表示
        self.mapView.setCenter(coordinate, animated: true)
        var region:MKCoordinateRegion = self.mapView.region
        region.center = coordinate
        region.span.latitudeDelta = 0.0001
        region.span.longitudeDelta = 0.0001
        self.mapView.setRegion(region, animated: true)
    }
    
    //ピンの設定
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if (annotation is MKUserLocation) {
            // ユーザの現在地の青丸マークは置き換えない
            return nil
        } else {

            let makerAnootationView = MKMarkerAnnotationView()

            makerAnootationView.markerTintColor = UIColor(red: 255/255, green: 145/255, blue: 77/255, alpha: 1.0)
     
            makerAnootationView.glyphImage = UIImage(systemName: "bicycle")
            
            makerAnootationView.clusteringIdentifier = "cycling"
            return makerAnootationView
        }
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        if view.annotation is MKUserLocation || view.annotation is MKClusterAnnotation {
            return
        }
        let pin = view.annotation as! MyAnnotation
        
        if blockListArray.contains(pin.documentID ?? "") {
            showBlockAlert(id: pin.documentID!)
        } else {
            guard let customVC = storyboard?.instantiateViewController(identifier: "fpc_content") as? InfoListViewController else {
                return
            }
            guard let c = view.annotation?.coordinate, let n = view.annotation?.title, let category = view.annotation?.subtitle else { return }

            customVC.coordinateInfo = c
            customVC.name = n ?? ""
            customVC.category = category ?? ""
            
            DispatchQueue.main.async {
                self.fpc.set(contentViewController: customVC)
                self.fpc.addPanel(toParent: self)
                self.fpc.move(to: .half, animated: true)
                self.fpc.track(scrollView: customVC.infoTableView)
            }
            
            //二回連続でタップするとうまく行かないので、選択後に選択を解除する
            mapView.deselectAnnotation(view.annotation, animated: false)
        }
        
        
    }
}

extension MapViewController: FloatingPanelControllerDelegate {
    // カスタマイズしたデザインパターンを返す
    private func floatingPanel(_ vc: FloatingPanelController, layoutFor newCollection: UITraitCollection) -> FloatingPanelLayout {
        return CustomFloatingPanelLayout()
    }
}
class MyAnnotation: MKPointAnnotation {
    var documentID: String?
}

extension Array where Element: Equatable {
    mutating func remove(value: Element) {
        if let i = self.firstIndex(of: value) {
            self.remove(at: i)
        }
    }
}
