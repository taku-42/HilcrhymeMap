import UIKit
import Cosmos
import UITextView_Placeholder
import Firebase
import FirebaseStorage

class CommentViewController: UIViewController {

    @IBOutlet weak var titleLable: UILabel!
    
    @IBOutlet weak var userNameTextField: UITextField!

    @IBOutlet weak var commentTextView: UITextView!
    
    @IBOutlet weak var osusumeRate: CosmosView!
    
    @IBOutlet weak var hardRate: CosmosView!
    
    @IBOutlet weak var viewRate: CosmosView!
    
    @IBOutlet weak var easyToRideRate: CosmosView!

    var numberOfStars: Double?
    
    var pinID: String?
    
    var spotName: String?
    
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLable.text = spotName ?? "名称が設定されていません"
        
        commentTextView.placeholder = "この場所での辛い体験やアドバイスを共有しましょう"
        
        osusumeRate.didTouchCosmos = {rating in
            self.numberOfStars = rating
        }
        
        view.layer.cornerRadius = 5.0

        view.layer.shadowColor = UIColor(displayP3Red: 0.0, green: 0.0, blue: 0.0, alpha: 0.6).cgColor
        view.layer.shadowOffset = CGSize(width: 3, height: 3)
        view.layer.shadowOpacity = 0.3
        view.layer.shadowRadius = 5
    }
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @IBAction func sendButtonPressed(_ sender: UIButton) {
//        uploadImage()
        
        dismiss(animated: true)
        guard let pinIDBody = pinID else { return }
        let userNameBody = userNameTextField.text
        let commentBody = commentTextView.text
        
        let f = DateFormatter()
        f.dateStyle = .long
        f.locale = Locale(identifier: "ja_JP")
        
        let commentRef = db.collection("advise").document("\(pinIDBody)")
        commentRef.collection("comments").addDocument(data: [
            "name": userNameBody ?? "",
            "comment": commentBody ?? "",
            "osusumeRating": osusumeRate.rating,
            "hardRating": hardRate.rating,
            "viewRating": viewRate.rating,
            "easyToRideRating": easyToRideRate.rating,
            "date": Timestamp(date: Date())
        ]){ (error) in
            if let e = error {
                print("There was an error saving comment to firestore, \(e)")
            } else {
                print("successfuly")
            }
        }
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        self.view.endEditing(true)
        
        if (self.commentTextView.isFirstResponder) {
            self.commentTextView.resignFirstResponder()
        }
    }
    
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//            self.view.endEditing(true)
//    }
    
//    func uploadImage() {
//        let storage = Storage.storage()
//
//        let storageRef = storage.reference()
//
//        let currentTimeStampInSecond = UInt64(floor(Date().timeIntervalSince1970 * 1000))
//
//        let imagesRef = storageRef.child("\(pinID!)").child("\(currentTimeStampInSecond).jpg")
//
//        let metaData = StorageMetadata()
//
//        if let uploadData = self.imageView.image?.jpegData(compressionQuality: 0.9) {
//            imagesRef.putData(uploadData, metadata: metaData) { (metaData, error) in
//                if let e = error {
//                    print("There was an error uploading image to storage, \(e.localizedDescription)")
//                }
//                storageRef.downloadURL { (url, error) in
//                    if let e = error {
//                        print("There was an issue downloading URL from storage, \(e.localizedDescription)")
//                    }
//                    print("url: \(url?.absoluteString)")
//                }
//            }
//
//        }
//    }

}

//extension CommentViewController:  UIImagePickerControllerDelegate, UINavigationControllerDelegate {
//    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
//        
//        if let pickedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
//            imageView.contentMode = .scaleAspectFit
//            imageView.image = pickedImage
//        }
//        self.dismiss(animated: true)
//    }
//}
