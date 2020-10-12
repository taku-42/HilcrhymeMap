import UIKit
import Eureka
import Firebase
import MapKit

class EditViewController: FormViewController {
    
    let db = Firestore.firestore()

    var elevationList = ["わからない"]
    
    var distanceList = ["わからない"]
    
    let choicesList = ["あり", "なし", "わからない"]
    
    var info: PinData?
    
    var documentID: String?
    
    var coordinate: CLLocationCoordinate2D?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setUpList()
        setUpForm()
    }
    
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @IBAction func completeButtonPressed(_ sender: UIButton) {
        let values = form.values()
        
        if let path = documentID, let coordinateBody = coordinate {
            db.collection("advise").document(path).setData([
                                                    "name": values["name"] as! String,
                                                    "category": values["category"] as! String,
                                                    "elevationGain": values["elevationGain"] as! String,
                                                    "distance": values["distance"] as! String,
                                                    "condition": values["condition"] as! String,
                                                    "traficVolume": values["traficVolume"] as! String,
                                                    "supplySpot": values["supplySpot"] as! String,
                                                    "winter": values["winter"] as! String,
                                                    "tunnel": values["tunnel"] as! String,
                                                    "curve": values["curve"] as! String,
                                                    "memo": values["memo"] as! String,
                                                    "coordinate": GeoPoint(latitude: coordinateBody.latitude, longitude: coordinateBody.longitude)
            ]){ (error) in
                if let e = error {
                    print("There was an issue saving data to firestore, \(e)")
                } else {
                    print("successfuly")
                }
            }
        }
        
        dismiss(animated: true)
        
    }
}

//MARK: - form methods

extension EditViewController {
    func setUpList() {
        for i in stride(from: 100, to: 2001, by: 100) {
            elevationList.append("\(i)m")
        }
        
        for i in stride(from: 0.5, to: 20.1, by: 0.5) {
            distanceList.append("\(i)km")
        }
    }
    
    
    func setUpForm() {
        if let info = info {
            form +++ Section("基本情報")
                <<< TextRow("name"){ row in
                    row.title = "名称"
                    row.value = info.name
                }
                <<< TextRow("category"){ row in
                    row.title = "カテゴリー"
                    row.value = info.category
                }
            
            form +++ Section(footer: "おおよその値で大丈夫です")
                
                <<< PickerInlineRow<String>("elevationGain") { row in
                    
                    row.title = "獲得標高（約）"
                    
                    row.options = elevationList
                    
                    row.value = info.elevationGain
                    
                }
                <<< PickerInlineRow<String>("distance") { row in
                    
                    row.title = "上り坂の距離（約）"
                    
                    row.options = distanceList
                    
                    row.value = info.distance
                }

            form +++ Section(header: "道路情報", footer: "(分かる範囲でお願いします)")
                <<< ActionSheetRow<String>("condition"){ row in
                    row.title = "路面状況"
                    row.options = ["良い", "普通", "悪い", "わからない"]
                    row.value = info.condition
                }
                <<< ActionSheetRow<String>("traficVolume"){ row in
                    row.title = "交通量"
                    row.options = ["多い", "普通", "少ない", "わからない"]
                    row.value = info.traficVolume
                }
                
                <<< ActionSheetRow<String>("supplySpot"){ row in
                    row.title = "補給場所"
                    row.options = ["直前で買える", "事前に買っておいたほうがいい", "わからない"]
                    row.value = info.supplySpot
                }
                <<< ActionSheetRow<String>("winter"){ row in
                    row.title = "冬季封鎖あり"
                    row.options = choicesList
                    row.value = info.winter
                }
                <<< ActionSheetRow<String>("tunnel"){ row in
                    row.title = "トンネルあり"
                    row.options = choicesList
                    row.value = info.tunnel
                }
                <<< ActionSheetRow<String>("curve"){ row in
                    row.title = "急カーブあり"
                    row.options = choicesList
                    row.value = info.curve
                }
               
            form +++ Section("メモ")
                <<< TextAreaRow("memo"){ row in
                    row.value = info.memo
                }
        }
    }
}
