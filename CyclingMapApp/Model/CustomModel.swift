//import UIKit
//import Firebase
//import MapKit
//
//class CustomModel {
//    
//    var db = Firestore.firestore()
//    
//    var pinData: PinData?
//    
//    func pinData(c: CLLocationCoordinate2D) {
//        db.collection("advise").whereField("coordinate", isEqualTo: GeoPoint(latitude: c.latitude, longitude: c.longitude)).getDocuments { (querySnapshot, error) in
//            if let e = error {
//                print("There was an error gettitg pin's document, \(e)")
//            } else {
//                if let snapshotDocuments = querySnapshot?.documents {
//                    for doc in snapshotDocuments {
//                        let data = doc.data()
//                    }
//                }
//    }
//}
