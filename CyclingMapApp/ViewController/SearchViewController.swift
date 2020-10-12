import UIKit
import MapKit

protocol SearchViewDelegate: class {
    func setSearchRegion(coordinate: CLLocationCoordinate2D)
}

class SearchViewController: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var tableView: UITableView!
    
    var results: [MKMapItem]?

    var resultHandler: ((CLLocationCoordinate2D?) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        searchBar.backgroundImage = UIImage()
        
        searchBar.delegate = self
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        searchBar.text = ""
    }
    
    func placeSearch(_ query: String) {
        let coordinate = CLLocationCoordinate2DMake(35.6598051, 139.7036661) // 渋谷ヒカリエ
        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 1000.0, longitudinalMeters: 1000.0)
        
        Map.search(query: query, region: region) { (result) in
            switch result {
            case .success(let mapItems):
                self.results = mapItems
                DispatchQueue.main.async {
                    self.tableView.reloadData()

                }
            case .failure(let error):
                print("error \(error.localizedDescription)")
            }
        }
    }
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        dismiss(animated: true)
    }
}

extension SearchViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let query = searchBar.text!
        placeSearch(query)
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar){
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.setShowsCancelButton(false, animated: true)
    }
}

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results?.count ?? 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let r = results {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) //as! SearchTableViewCell
            let completion = r[indexPath.row]
            cell.textLabel?.text = completion.name
            cell.detailTextLabel?.text = completion.placemark.address
            return cell
        } else {
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let handler = resultHandler {
            let spot = results?[indexPath.row]
            handler(spot?.placemark.coordinate)
        } else {
            return
        }
        dismiss(animated: true)
    }
}

extension MKPlacemark {
    var address: String {
        let components = [self.administrativeArea, self.locality, self.thoroughfare, self.subThoroughfare]
        return components.compactMap { $0 }.joined(separator: "")
    }
}
