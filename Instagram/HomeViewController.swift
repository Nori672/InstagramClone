//
//  HomeViewController.swift
//  Instagram
//
//  Created by Norihiro.Nakano on 2021/01/02.
//  Copyright © 2021 Norihiro.Nakano. All rights reserved.
//


//PostTableViewCellで作ったセルを、HomeViewControllerに表示させる処理を記入
import UIKit
import Firebase

class HomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{
    @IBOutlet weak var tableView: UITableView! 
    
    // 投稿データを格納する配列
    var postArray: [PostData] = []
    
    // Firestoreのリスナー。Firestoreのデータ更新の監視を行うためのプロパティを作成
    var listener: ListenerRegistration!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self

        // カスタムセルを登録する
        let nib = UINib(nibName: "PostTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "Cell")
        //PostTableViewCellで作成したカスタムセルを「Cell」という名前でIdentifierに登録
        //カスタムセルの登録方法
        //1. UINib(nibName:bundle)を使ってxibファイルを読み込み
        //2. 1.で読み込んだファイルをregister(_:forCellReuseIdentifier:)メソッドで登録。

        // Do any additional setup after loading the view.
    }
    
    //投稿データを読み込む処理
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("DEBUG_PRINT: viewWillAppear")
        
        //現在のログイン状態を確認し、それぞれの場合の処理を記入
        if Auth.auth().currentUser != nil { // ログイン済みの場合
            if listener == nil { // listener未登録なら、登録してスナップショットを受信する
                let postsRef = Firestore.firestore().collection(Const.PostPath).order(by: "date", descending: true)
                //投稿データを読み込むために、まずはデータベースの参照場所と取得順序を指定したクエリを作成。
                
                listener = postsRef.addSnapshotListener() { (querySnapshot, error) in //postRefで取得できるドキュメントを addSnapshotListenerメソッドで監視。ドキュメントの追加や更新があるたびに何度も呼び出す。
                    if let error = error {
                        print("DEBUG_PRINT: snapshotの取得が失敗しました。 \(error)")
                        return
                    }
                    // 取得したdocumentをもとにPostDataを作成し、postArrayの配列にする。
                    self.postArray = querySnapshot!.documents.map { document in
                        print("DEBUG_PRINT: document取得 \(document.documentID)")
                        let postData = PostData(document: document)
                        return postData
                    }
                    //mapメソッド:配列の要素を変換して新しい配列を作成するメソッド。
                    //mapメソッドのクロージャの引数（document）で変換元の配列要素を受け取り、変換した要素をクロージャの戻り値（return postData）で返却することにより、配列を変換。
                    
                    // TableViewの表示を更新する
                    self.tableView.reloadData()
                }
            }
        } else {
            // ログイン未(またはログアウト済み)
            if listener != nil {
                // listener登録済みなら削除してpostArrayをクリアする
                listener.remove()
                listener = nil
                postArray = []
                tableView.reloadData()
            }
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postArray.count
    }
    //テーブル表示のための必須デリゲート。今回はpostArrayの配列の要素数を返す

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // セルを取得してデータを設定する
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! PostTableViewCell
        cell.setPostData(postArray[indexPath.row])
        
        // HomeViewController内でアプリの機能に関わるデータが格納されているため、PostTableViewCellのセル内のボタンのアクションをソースコードで設定。(処理をしやすくするため)
        cell.likeButton.addTarget(self, action:#selector(handleButton(_:forEvent:)), for: .touchUpInside)
        //cell内のlikeButtonに対して、addTarget(_:action:for:)を使ってメソッドを登録。(storyboardで青い線を引っ張ってAction設定する代わりになる)
        //第一引数をselfにして、自分自身を呼び出し対象に設定。第二引数(action)の#selectorで指定したメソッドを呼び出す。
        
// (課題用に追加) セル内のボタンアクションを設定(コメント入力ボタン)
        cell.commentButton.addTarget(self, action: #selector(handleCommentButton(_:forEvent:)
            ), for: .touchUpInside)
        
        return cell
    }
    //テーブル表示のための必須デリゲート。
    
    
    // セル内のボタン(likeボタン)がタップされた時に呼ばれるメソッド
    @objc func handleButton(_ sender: UIButton, forEvent event: UIEvent) { //selector指定で呼び出されるメソッドは、先頭に @objcを付与してメソッドを宣言。
        print("DEBUG_PRINT: likeボタンがタップされました。")

        // タップされたセルのインデックスを求める
        let touch = event.allTouches?.first //タッチ情報を取り出す
        let point = touch!.location(in: self.tableView) //タッチした座標（TableView内の座標）を割り出す
        let indexPath = tableView.indexPathForRow(at: point) //タッチした座標がtableView内のどのindexPath位置になるのかを取得。


        // 配列からタップされたセルの投稿データを取り出す
        let postData = postArray[indexPath!.row]

        // likesを更新する
        if let myid = Auth.auth().currentUser?.uid {
            // 更新データを作成する
            var updateValue: FieldValue
            if postData.isLiked {
                // すでにいいねをしている場合は、いいね解除のためmyidを取り除く更新データを作成
                updateValue = FieldValue.arrayRemove([myid])
            } else {
                // 今回新たにいいねを押した場合は、myidを追加する更新データを作成
                updateValue = FieldValue.arrayUnion([myid])
            }
            // likesに更新データを書き込む
            let postRef = Firestore.firestore().collection(Const.PostPath).document(postData.id)
            postRef.updateData(["likes": updateValue])
        }
    }
    
    
    
// (課題用に追加)   セル内のコメントボタンがよばれた時のメソッド
    @objc func handleCommentButton(_ sender: UIButton, forEvent event: UIEvent) {
        print("DEBUG_PRINT: コメント入力ボタンがタップされました。")
        
        // タップされたセルのインデックスを求める
        let touch = event.allTouches?.first //タッチ情報を取り出す
        let point = touch!.location(in: self.tableView) //タッチした座標（TableView内の座標）を割り出す
        let indexPath = tableView.indexPathForRow(at: point)

        // 配列からタップされたセルの投稿のデータを取り出す
        let postData = postArray[indexPath!.row]
        
        //CommentViewController画面を開く
        let commentViewController = storyboard?.instantiateViewController(withIdentifier: "CommentView")
        
        if let commentController = commentViewController as? CommentViewController{
            commentController.postData = postData
        }
        
        
        self.present(commentViewController!, animated: true, completion: nil)
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
