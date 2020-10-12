import UIKit
import Firebase
import MapKit

class InfoListViewController: UIViewController {
    
    @IBOutlet weak var infoTableView: UITableView!
    
    let mapViewController = MapViewController()
    
    var headerView: InfoListHeaderView!

    var name = ""
    
    var category = ""
    
    var documentID: String?
    
    var coordinateInfo: CLLocationCoordinate2D?
    
    var memoText: String?
    
    let db = Firestore.firestore()
    
    let defaults = UserDefaults.standard
    
    var blockListArray: [String] = []
    
    var comments: [Comment] = [] {
        didSet {
            if pinData == nil {
                infoTableView.backgroundView = UIView()
//                infoTableView.tableFooterView = UIView()
            } else if comments.count == 0 {
                infoTableView.backgroundView = UIView()
                infoTableView.tableFooterView = EmptyTableView(frame: CGRect(x: 0, y: 0, width: infoTableView.bounds.width, height: 300))
            } else {
                infoTableView.tableFooterView = UIView()
            }
        }
    }
    
    var pinData: PinData?
    
    var editCallBack: ((Bool) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(#function)
        
        loadInfo()
        setUpTableView()
        
        if let blockLists = defaults.array(forKey: "BlockListArray") as? [String] {
            blockListArray = blockLists
        }
    }
    
    func setUpTableView() {
        infoTableView.delegate = self
        infoTableView.dataSource = self
        
        infoTableView.register(UINib(nibName: "InfoListFirstViewCell", bundle: nil), forCellReuseIdentifier: "InfoListFirstViewCell")
        infoTableView.register(UINib(nibName: "InfoListMemoViewCell", bundle: nil), forCellReuseIdentifier: "InfoListMemoViewCell")
        infoTableView.register(UINib(nibName: "InfoListCommentViewCell", bundle: nil), forCellReuseIdentifier: "InfoListCommentViewCell")
        
        
        
        infoTableView.tableHeaderView = InfoListHeaderView(frame: CGRect(x: 0, y: 0, width: infoTableView.bounds.width, height: 150))
        
        headerView = infoTableView.tableHeaderView as? InfoListHeaderView
        
        headerView.delegate = self
        
        if name == "" {
            headerView.nameLabel.text = "名称が設定されていません"
        } else {
            headerView.nameLabel.text = name
        }
        
        headerView.categoryLabel.text = category
    }
    
    func loadInfo() {
        print(#function)
        if let c = coordinateInfo {
            db.collection("advise").whereField("coordinate", isEqualTo: GeoPoint(latitude: c.latitude, longitude: c.longitude)).getDocuments { (querySnapshot, error) in
                if let e = error {
                    print("There was an error gettitg pin's document, \(e)")
                } else {
                    if let snapshotDocuments = querySnapshot?.documents {
                        for doc in snapshotDocuments {
                            let data = doc.data()
                            
                            self.documentID = doc.documentID
                            self.memoText = data["memo"] as? String ?? ""
                            if let coordinate = data["coordinate"] as? GeoPoint {
                                let c = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
                                
                                self.pinData = PinData(name: data["name"] as? String ?? "",
                                                       category: data["category"] as? String ?? "",
                                                       elevationGain: data["elevationGain"] as? String ?? "",
                                                       distance: data["distance"] as? String ?? "",
                                                       condition: data["condition"] as? String ?? "",
                                                       traficVolume: data["traficVolume"] as? String ?? "",
                                                       supplySpot: data["supplySpot"] as? String ?? "",
                                                       winter: data["winter"] as? String ?? "",
                                                       tunnel: data["tunnel"] as? String ?? "",
                                                       curve: data["curve"] as? String ?? "",
                                                       memo: data["memo"] as? String ?? "",
                                                       coordinate: c,
                                                       id: data["id"] as? String ?? ""
                                                       
                                )
                            }
                        }
//                        if self.pinData?.name == "" {
//                            self.nameLabel.text = "名称が設定されていません"
//                        } else {
//                            self.nameLabel.text = self.pinData?.name
//                        }
//                        self.categoryLabel.text = self.pinData?.category
                        self.infoTableView.reloadData()
                        self.loadComment()
                    }
                }
            }
        }
    }
    
    func loadComment() {
        db.collection("advise").document("\(documentID ?? "")")
            .collection("comments").order(by: "date", descending: true).addSnapshotListener { (querySnapshot, error) in
                self.comments = []
                if let e = error {
                    print("There was an issue retreving data fron firebase, \(e)")
                } else {
                    if let snapShotDocuments = querySnapshot?.documents {
                        for doc in snapShotDocuments {
                            let data = doc.data()
                            let nameBody = data["name"] as? String
                            let commentBody = data["comment"] as? String
                            let rating = data["osusumeRating"] as? Double
                            let hardRate = data["hardRating"] as? Double
                            let viewRate = data["viewRating"] as? Double
                            let easyToRideRate = data["easyToRideRating"] as? Double
                            guard let timeStamp = data["date"] as? Timestamp else { return }
                            
                            let f = DateFormatter()
                            f.dateStyle = .long
                            f.locale = Locale(identifier: "ja_JP")
                            let dateBody = f.string(from: timeStamp.dateValue())
                            
                            let newComment = Comment(name: nameBody ?? "",
                                                     comment: commentBody ?? "",
                                                     rating: rating ?? 1.0,
                                                     date: dateBody,
                                                     hardRate: hardRate ?? 1.0,
                                                     viewRate: viewRate ?? 1.0,
                                                     easyToRideRate: easyToRideRate ?? 1.0
                            )
                            self.comments.append(newComment)
                            
                            DispatchQueue.main.async {
                                self.infoTableView.reloadData()
                            }
                        }
                    }
                }
            }
        
    }
    
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @IBAction func postCommentButtonPressed(_ sender: UIButton) {
        
    }
    
    @IBAction func editButtonPressed(_ sender: UIButton) {
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toCommentViewController" {
            let vc = segue.destination as! CommentViewController
            vc.pinID = documentID
//            vc.spotName = nameLabel.text
        } else if segue.identifier == "toEditViewController" {
            let nc = segue.destination as! UINavigationController
            let vc = nc.topViewController as! EditViewController
            vc.info = pinData
            vc.documentID = self.documentID
            vc.coordinate = pinData?.coordinate
        } else if segue.identifier == "toMapEditViewController" {
            let vc = segue.destination as! MapEditViewController
            vc.coordinate = self.coordinateInfo
            vc.documetID = self.documentID
        }
    }
}

//MARK: - private Method
extension InfoListViewController {
    
    private func setUpEditActionSheet() {
        let alertSheet = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        
        // 自分の選択肢を生成
        let action1 = UIAlertAction(title: "情報を編集する", style: UIAlertAction.Style.default, handler: {
            (action: UIAlertAction!) in
            self.performSegue(withIdentifier: "toEditViewController", sender: nil)
        })
        
        let action3 = UIAlertAction(title: "位置を修正する", style: UIAlertAction.Style.default) { (action: UIAlertAction) in
            self.performSegue(withIdentifier: "toMapEditViewController", sender: nil)
        }
        let action4 = UIAlertAction(title: "キャンセル", style: UIAlertAction.Style.cancel, handler: {
            (action: UIAlertAction!) in
        })
        
        // アクションを追加.
        alertSheet.addAction(action1)
        alertSheet.addAction(action3)
        alertSheet.addAction(action4)
        
        self.present(alertSheet, animated: true, completion: nil)
    }
    
    private func setUpDeleteActionSheet() {
        let alertSheet = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        
        let action1 = UIAlertAction(title: "削除依頼をする", style: UIAlertAction.Style.default, handler: {
            (action: UIAlertAction!) in
            self.showDeleteAlert()
        })
        
        let action2 = UIAlertAction(title: "表示をブロックする", style: UIAlertAction.Style.default, handler: {
            (action: UIAlertAction!) in
            self.showBlockAlert()
        })
        
        let action3 = UIAlertAction(title: "キャンセル", style: UIAlertAction.Style.cancel, handler: {
            (action: UIAlertAction!) in
        })
        
        alertSheet.addAction(action1)
        alertSheet.addAction(action2)
        alertSheet.addAction(action3)
        
        self.present(alertSheet, animated: true, completion: nil)
    }
    
    private func showDeleteAlert() {
        let alert = UIAlertController(title: "削除依頼をする", message: "誤って投稿してしまった場合や、不適切なコンテンツが含まれている場合に、情報の削除を依頼することができます。\n削除依頼をしますか？", preferredStyle: UIAlertController.Style.alert)
        
        let defaultAction = UIAlertAction(title: "はい", style: UIAlertAction.Style.destructive, handler: {
            (action: UIAlertAction!) -> Void in
            self.db.collection("deleteTasks").addDocument(data: [
                "name": self.name,
                "id": self.documentID ?? ""
            ]) { (error) in
                if let e = error {
                    print("There was an issue saving data to firestore, \(e)")
                }
            }
        })
        
        let cancelAction = UIAlertAction(title: "いいえ", style: UIAlertAction.Style.default, handler: { (action: UIAlertAction!) -> Void in
        })
        
        alert.addAction(defaultAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    private func showBlockAlert() {
        let alert = UIAlertController(title: "表示をブロックする", message: "不適切な内容が含まれているなどして、今後このスポットを表示したくない場合はスポットをブロックすることができます。\nブロックしますか？", preferredStyle: UIAlertController.Style.alert)
        
        let defaultAction = UIAlertAction(title: "はい", style: UIAlertAction.Style.destructive, handler: {
            (action: UIAlertAction!) -> Void in
            if let id = self.documentID {
//                let mapVC = self.presentingViewController as! MapViewController
                self.blockListArray.append(id)
                self.defaults.set(self.blockListArray, forKey: "BlockListArray")
//                mapVC.blockListArray = self.blockListArray
            }
        })
        
        let cancelAction = UIAlertAction(title: "いいえ", style: UIAlertAction.Style.default, handler: { (action: UIAlertAction!) -> Void in
        })
        
        alert.addAction(defaultAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
    }
}

extension InfoListViewController: UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        if pinData != nil {
            return 5
        } else {
            return 0
        }
    }
}

extension InfoListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return 6
        case 2:
            return 1
        case 3:
            return 0
        default:
            return comments.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
//        print(#function)
        
        if let data = pinData {
            switch indexPath.section {
            case 0:
                let cell = infoTableView.dequeueReusableCell(withIdentifier: "InfoListFirstViewCell", for: indexPath) as! InfoListFirstViewCell
                cell.elevationGainLabel.text = data.elevationGain
                cell.distanceLabel.text = data.distance
                return cell
            case 1:
                let cell = infoTableView.dequeueReusableCell(withIdentifier: "detailCell", for: indexPath)
                switch indexPath.row {
                case 0:
                    cell.textLabel?.text = "路面状況"
                    cell.detailTextLabel?.text = data.condition
                case 1:
                    cell.textLabel?.text = "交通量"
                    cell.detailTextLabel?.text = data.traficVolume
                case 2:
                    cell.textLabel?.text = "補給場所"
                    cell.detailTextLabel?.text = data.supplySpot
                case 3:
                    cell.textLabel?.text = "冬季封鎖"
                    cell.detailTextLabel?.text = data.winter
                case 4:
                    cell.textLabel?.text = "トンネル"
                    cell.detailTextLabel?.text = data.tunnel
                default:
                    cell.textLabel?.text = "急カーブ"
                    cell.detailTextLabel?.text = data.curve
                }
                return cell
            case 2:
                let cell = infoTableView.dequeueReusableCell(withIdentifier: "InfoListMemoViewCell", for : indexPath) as! InfoListMemoViewCell
                cell.memoLabel.text = data.memo
//                cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
                return cell
            case 3:
                let cell = infoTableView.dequeueReusableCell(withIdentifier: "commentButtonCell", for: indexPath)
                return cell
            default:
                let comment = comments[indexPath.row]
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "InfoListCommentViewCell") as! InfoListCommentViewCell
                
                cell.nameLabel.text = comment.name
                cell.commentLabel.text = comment.comment
                cell.dateLabel.text = comment.date
                cell.cosmosView.rating = comment.rating
                cell.detailLabel.text = "キツイ \(Int(comment.hardRate)) / ゼッケイ \(Int(comment.viewRate)) / 走りやすさ \(Int(comment.easyToRideRate))"
                return cell
            }
        } else {
            return UITableViewCell()
        }
    }
}


extension InfoListViewController: InfoListHeaderViewDelegate {
    
    func backButtonPressed() {
         dismiss(animated: true)
    }
    
    func postButtonPressed() {
        performSegue(withIdentifier: "toCommentViewController", sender: nil)
    }
    
    func editButtonPressed() {
        setUpEditActionSheet()
    }
    
    func deleteButtonPressed() {
        setUpDeleteActionSheet()
    }
}
