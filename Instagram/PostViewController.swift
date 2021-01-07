//
//  PostViewController.swift
//  Instagram
//
//  Created by Norihiro.Nakano on 2021/01/02.
//  Copyright © 2021 Norihiro.Nakano. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class PostViewController: UIViewController {
    var image:UIImage!
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textField: UITextField!
    
    // 投稿ボタンをタップしたときに呼ばれるメソッド
    @IBAction func handlePostButton(_ sender: Any) {
        // 画像をJPEG形式に変換する
        let imageData = image.jpegData(compressionQuality: 0.75)
        //compressionQualityで指定しているのは、JPEG形式に変換する時の圧縮率で値が小さいほど圧縮率が高い
        //圧縮率が高いと画像が粗くなるが、変換後のデータサイズは減る。
        
        // 画像と投稿データの保存場所を定義する
        let postRef = Firestore.firestore().collection(Const.PostPath).document() //Firestoreに保存する投稿データの保存場所を定義
        let imageRef = Storage.storage().reference().child(Const.ImagePath).child(postRef.documentID + ".jpg") //Storageに保存する画像の保存場所を定義
        // HUDで投稿処理中の表示を開始
        SVProgressHUD.show()
        
        // putData(_:metadata:completion:)メソッドを使用してStorageに画像をアップロードする
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg" //画像を保存する際のファイル形式を指定
        imageRef.putData(imageData!, metadata: metadata) { (metadata, error) in
            if error != nil {
                // 画像のアップロード失敗
                print(error!)
                SVProgressHUD.showError(withStatus: "画像のアップロードが失敗しました")
                // 投稿処理をキャンセルし、先頭画面(TabBarController)に戻る
                //PostViewControllerは、先頭(TabBar)->ImageSelectView->UIImagePicker->CLImageEditor->PostViewControllerと画面遷移しているので、先頭に戻るには、複数の画面を一気にもどる必要がある
                UIApplication.shared.windows.first{ $0.isKeyWindow }?.rootViewController?.dismiss(animated: true, completion: nil)
                //このメソッドを実行することで先頭まで一気に戻れる
                
                return
            }
            // FireStoreに投稿データ(投稿者、キャプション、投稿日時)を保存する
            let name = Auth.auth().currentUser?.displayName
            let postDic = [
                "name": name!,
                "caption": self.textField.text!,
                "date": FieldValue.serverTimestamp(),
                ] as [String : Any]
            postRef.setData(postDic) //setDataメソッドでFirestoreに保存できる。
            //投稿日時はFieldValue.serverTimestamp()を指定しており、これは、Firestoreのサーバー上の時計を使用している。
            
            // HUDで投稿完了を表示する
            SVProgressHUD.showSuccess(withStatus: "投稿しました")
            
            // 投稿処理が完了したので先頭画面に戻る
           UIApplication.shared.windows.first{ $0.isKeyWindow }?.rootViewController?.dismiss(animated: true, completion: nil)
        }
    }
    
    // キャンセルボタンをタップしたときに呼ばれるメソッド
    @IBAction func handleCancelButton(_ sender: Any) {
        // 加工画面に戻る
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //受け取った画像をImageViewに設定
        imageView.image = image

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
