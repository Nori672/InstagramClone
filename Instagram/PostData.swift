//
//  PostData.swift
//  Instagram
//
//  Created by Norihiro.Nakano on 2021/01/03.
//  Copyright © 2021 Norihiro.Nakano. All rights reserved.
//


//HomeViewController用に投稿データを格納するクラスを作成
import UIKit
import Firebase

class PostData: NSObject {
    var id: String //投稿者ID
    var name: String? //投稿者名
    var caption: String? //キャプション
    var date: Date? //日付
    var likes: [String] = [] //いいねをおしたユーザーIDを保持する配列
    var isLiked: Bool = false //自分がいいねを押したかどうかのフラグ
    //QueryDocumentSnapshotクラスから取り出すのではなく、likesというキーで取り出したString型の配列の中にユーザー自身のIDが入っているかでture,falseのどちらかで設定する
    
//    課題用に追加
    var comment:[String] = []


    init(document: QueryDocumentSnapshot) { //QueryDocumentSnapshot:Firestoreからデータを取得すると渡されるクラス
        self.id = document.documentID

        let postDic = document.data()

        self.name = postDic["name"] as? String

        self.caption = postDic["caption"] as? String

        let timestamp = postDic["date"] as? Timestamp
        self.date = timestamp?.dateValue()
        
        if let likes = postDic["likes"] as? [String] {
            self.likes = likes
        }
        if let myid = Auth.auth().currentUser?.uid {
            // likesの配列の中にmyid(ユーザー自身のID)が含まれているかチェックすることで、自分がいいねを押しているかを判断
            if self.likes.firstIndex(of: myid) != nil {
                // myidがあれば、いいねを押していると認識する。
                self.isLiked = true
            }
        }
        
// (課題用に追加)   コメント
        if let comment = postDic["comment"] as? [String] {
            self.comment = comment
        }
        
    }
}
