import UIKit
import Eureka
import Firebase
import MapKit

class NewRegistViewController: FormViewController {
    
    var resultHandler: ((Bool) -> Void)?
    
    let db = Firestore.firestore()
    
    var coordinate: CLLocationCoordinate2D?
    
    var elevationList = ["わからない"]
    
    var distanceList = ["わからない"]
    
    let choicesList = ["あり", "なし", "わからない"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpList()
        
        setUpForm()
    }
    
    func setUpList() {
        for i in stride(from: 100, to: 2001, by: 100) {
            elevationList.append("\(i)m")
        }
        
        for i in stride(from: 0.5, to: 20.1, by: 0.5) {
            distanceList.append("\(i)km")
        }
    }
    
    @IBAction func backButtonPressed(_ sender: UIBarButtonItem) {
        showBackAlert()
    }
    
    @IBAction func saveButtonPressed(_ sender: UIBarButtonItem){
        let values = form.values()

        if let handler = resultHandler {
            handler(true)
        }
        
        if let coordinateBody = coordinate {
            db.collection("advise").addDocument(data: [
                                                    "name": values["name"] as? String ?? "",
                                                    "category": values["category"] as? String ?? "",
                                                    "elevationGain": values["elevationGain"] as? String ?? "",
                                                    "distance": values["distance"] as? String ?? "",
                                                    "condition": values["condition"] as? String ?? "わからない",
                                                    "traficVolume": values["traficVolume"] as? String ?? "わからない",
                                                    "supplySpot": values["supplySpot"] as? String ?? "わからない",
                                                    "winter": values["winter"] as? String ?? "わからない",
                                                    "tunnel": values["tunnel"] as? String ?? "わからない",
                                                    "curve": values["curve"] as? String ?? "わからない",
                                                    "memo": values["memo"] as? String ?? "",
                                                    "coordinate": GeoPoint(latitude: coordinateBody.latitude, longitude: coordinateBody.longitude)
            ]) { (error) in
                if let e = error {
                    print("There was an issue saving data to firestore, \(e)")
                } else {
                    print("successfuly")
                }
            }
        }
        
        dismiss(animated: true)
    }
    
    private func showBackAlert() {
        let alert = UIAlertController(title: "編集を終了してもいいですか？", message: "入力した内容は破棄されます", preferredStyle: UIAlertController.Style.alert)
        
        let defaultAction = UIAlertAction(title: "はい", style: UIAlertAction.Style.destructive, handler: {
            (action: UIAlertAction!) -> Void in
            self.dismiss(animated: true)
        })
        
        let cancelAction = UIAlertAction(title: "編集を続ける", style: UIAlertAction.Style.default, handler: { (action: UIAlertAction!) -> Void in
        })
        
        alert.addAction(defaultAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
    }
}


//MARK: - Set Up Eureka Form

extension NewRegistViewController {
    
    func setUpForm() {
        form +++ Section("基本情報")
            <<< TextRow("name"){ row in
                row.title = "名称"
                row.placeholder = "地名、施設名など"
            }
            <<< TextRow("category"){ row in
                row.title = "カテゴリー"
                row.placeholder = "峠、展望台、スカイラインなど"
            }
        
        form +++ Section(footer: "おおよその値で大丈夫です")
            
            <<< PickerInlineRow<String>("elevationGain") { row in
                
                row.title = "獲得標高（約）"
                
                row.options = elevationList
                
                row.value = row.options.first
                
            }
            <<< PickerInlineRow<String>("distance") { row in
                
                row.title = "上り坂の距離（約）"
                
                row.options = distanceList
                
                row.value = row.options.first
            }

        form +++ Section(header: "道路情報", footer: "(分かる範囲でお願いします)")
            <<< ActionSheetRow<String>("condition"){ row in
                row.title = "路面状況"
                row.options = ["良い", "普通", "悪い", "わからない"]
                row.value = "わからない"
            }
            <<< ActionSheetRow<String>("traficVolume"){ row in
                row.title = "交通量"
                row.options = ["多い", "普通", "少ない", "わからない"]
                row.value = "わからない"
            }
            
            <<< ActionSheetRow<String>("supplySpot"){ row in
                row.title = "補給場所"
                row.options = ["直前で買える", "事前に買っておいたほうがいい", "わからない"]
                row.value = "わからない"
            }
            <<< ActionSheetRow<String>("winter"){ row in
                row.title = "冬季封鎖あり"
                row.options = choicesList
                row.value = "わからない"
            }
            <<< ActionSheetRow<String>("tunnel"){ row in
                row.title = "トンネルあり"
                row.options = choicesList
                row.value = "わからない"
            }
            <<< ActionSheetRow<String>("curve"){ row in
                row.title = "急カーブあり"
                row.options = choicesList
                row.value = "わからない"
            }
           
        form +++ Section("メモ")
            <<< TextAreaRow("memo"){ row in
                row.placeholder = "その他の情報\n(例) 冬季の通行止め期間、最終補給場所など"
            }
    }
}



