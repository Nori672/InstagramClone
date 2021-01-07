//
//  LoginViewController.swift
//  Instagram
//
//  Created by Norihiro.Nakano on 2021/01/02.
//  Copyright © 2021 Norihiro.Nakano. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD
//HUD:「ヘッドアップディスプレイ (Head-up Display)」の略で、iPhoneで音量変更する際などに画面に重ねて表示される半透明の表示を指す。
//ログイン処理などサーバと通信を行う際は、処理に時間がかかるかもしれないが、その間、ユーザは本当に動いているのか不安になってしまいます。それを軽減させるのがHUDの役目。



class LoginViewController: UIViewController {
    @IBOutlet weak var mailAddressTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var displayNameTextField: UITextField!
    
    //ログインボタンをタップした時のメソッド
    @IBAction func handleLoginButton(_ sender: Any) {
        if let address = mailAddressTextField.text, let password = passwordTextField.text {

             // アドレスとパスワード名のいずれかでも入力されていない時は何もしない
             if address.isEmpty || password.isEmpty {
                SVProgressHUD.showError(withStatus: "必要項目を入力して下さい") //SVProgressHUD.showError(withStatus: "表示させたい文字列"):エラーの旨を表すHUDを表示する。
                return
             }
            
            // HUDで処理中を表示
            SVProgressHUD.show()
            //SVProgressHUD.show():HUDの表示を開始。処理中を表したい時に使う。

             Auth.auth().signIn(withEmail: address, password: password) { authResult, error in
                 if let error = error {
                     print("DEBUG_PRINT: " + error.localizedDescription)
                     return
                 }
                 print("DEBUG_PRINT: ログインに成功しました。")
                
                // HUDを消す
                SVProgressHUD.dismiss()
                //SVProgressHUD.dismiss():HUDの表示を終了。 show() メソッドとセットで使う。

                // 画面を閉じてタブ画面に戻る
                self.dismiss(animated: true, completion: nil)
             }
         }
    }
    
    //アカウント作成ボタンをタップしたときのメソッド
    @IBAction func handleCreateAccountButton(_ sender: Any) {
        if let address = mailAddressTextField.text, let password = passwordTextField.text, let displayName = displayNameTextField.text {

            // アドレスとパスワードと表示名のいずれかでも入力されていない時は何もしない
            if address.isEmpty || password.isEmpty || displayName.isEmpty {
                print("DEBUG_PRINT: 何かが空文字です。")
                SVProgressHUD.showError(withStatus: "必要項目を入力して下さい")
                return
            }
            
            // HUDで処理中を表示
            SVProgressHUD.show()

            // アドレスとパスワードでユーザー作成。ユーザー作成に成功すると、自動的にログインする
            //※ここはクロージャで描かれており、本来は次のような書き方になる
            //Auth.auth().createUser(withEmail: address, password: password, completion: { authResult, error in
            // クロージャ内の処理
            //})
            Auth.auth().createUser(withEmail: address, password: password) { authResult, error in
                if let error = error {
                    // エラーがあったら原因をprintして、returnすることで以降の処理を実行せずに処理を終了する
                    print("DEBUG_PRINT: " + error.localizedDescription)
                    SVProgressHUD.showError(withStatus: "ユーザー作成に失敗しました。")
                    return
                }
                print("DEBUG_PRINT: ユーザー作成に成功しました。")

                // 表示名を設定する
                //Auth.auth().currentUser?.createProfileChangeRequest()でプロフィールを更新
                let user = Auth.auth().currentUser
                if let user = user {
                    let changeRequest = user.createProfileChangeRequest()
                    changeRequest.displayName = displayName
                    changeRequest.commitChanges { error in
                        if let error = error {
                            // プロフィールの更新でエラーが発生
                            print("DEBUG_PRINT: " + error.localizedDescription)
                            SVProgressHUD.showError(withStatus: "表示名の設定に失敗しました。")
                            return
                        }
                        print("DEBUG_PRINT: [displayName = \(user.displayName!)]の設定に成功しました。")
                        
                        // HUDを消す
                        SVProgressHUD.dismiss()

                        // 画面を閉じてタブ画面に戻る
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
