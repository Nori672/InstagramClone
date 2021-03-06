//
//  TabBarController.swift
//  Instagram
//
//  Created by Norihiro.Nakano on 2021/01/02.
//  Copyright © 2021 Norihiro.Nakano. All rights reserved.
//

import UIKit
import Firebase

class TabBarController: UITabBarController, UITabBarControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        // タブアイコンの色
        self.tabBar.tintColor = UIColor(red: 1.0, green: 0.44, blue: 0.11, alpha: 1)
        // タブバーの背景色
        self.tabBar.barTintColor = UIColor(red: 0.96, green: 0.91, blue: 0.87, alpha: 1)
        // UITabBarControllerDelegateプロトコルのメソッドをこのクラスで処理する。
        self.delegate = self

        // Do any additional setup after loading the view.
    }
    
    //ユーザーがログインしているかをviewDidApperのタイミングで確認
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // currentUserがnilならログインしていない
        if Auth.auth().currentUser == nil {
            // ログインしていないときの処理
            let loginViewController = self.storyboard?.instantiateViewController(withIdentifier: "Login")
            //instantiateViewController(withIdentifier:)メソッドの引数に、Storyboadに設定したStoryboad IDを与えることで該当のViewControllerを得ることができる
            
            self.present(loginViewController!, animated: true, completion: nil)
            
        }
    }
    
    // タブバーのアイコンがタップされた時に呼ばれるdelegateメソッドを処理する。
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if viewController is ImageSelectViewController {
            // ImageSelectViewControllerは、タブ切り替えではなくモーダル画面遷移する
            let imageSelectViewController = storyboard!.instantiateViewController(withIdentifier: "ImageSelect")
            //真ん中のボタン（投稿）が押された時は、instantiateViewController(withIdentifier:)メソッドを使ってStoryboardに定義されている ImageSelectViewControllerを読み込み
            
            present(imageSelectViewController, animated: true)
            //presentメソッドでモーダル画面遷移を行う
            return false
        } else {
            // その他のViewControllerは通常のタブ切り替えを実施
            return true
        }
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
