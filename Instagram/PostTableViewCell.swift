//
//  PostTableViewCell.swift
//  Instagram
//
//  Created by Norihiro.Nakano on 2021/01/03.
//  Copyright © 2021 Norihiro.Nakano. All rights reserved.
//

import UIKit
import FirebaseUI

class PostTableViewCell: UITableViewCell {
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var likeLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var captionLabel: UILabel!

    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var commentButton: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // PostDataの内容をセルに表示
    func setPostData(_ postData: PostData) {
        // 画像の表示
        postImageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
        //sd_imageIndicator: FirebaseUIをインポートすることで追加されるUIImageViewの新しいプロパティ。
        //FirebaseのCloud Storageから画像をダウンロードしている間、ダウンロード中であることを示すインジケーターを表示する。
        
        let imageRef = Storage.storage().reference().child(Const.ImagePath).child(postData.id + ".jpg")
        postImageView.sd_setImage(with: imageRef)
        //sd_imageIndicator: FirebaseUIをインポートすることで追加されるUIImageViewの新しいメソッド
        //メソッドの引数にCloud Storageの画像保存場所を指定するだけで自動的に指定場所から画像をダウンロードしてUIImageViewに表示。

        // キャプションの表示
        self.captionLabel.text = "\(postData.name!) : \(postData.caption!)"

        // 日時の表示
        self.dateLabel.text = ""
        if let date = postData.date {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm"
            let dateString = formatter.string(from: date)
            self.dateLabel.text = dateString
        }

        // いいね数の表示
        let likeNumber = postData.likes.count
        likeLabel.text = "\(likeNumber)"

        // いいねボタンの表示
        if postData.isLiked {
            let buttonImage = UIImage(named: "like_exist")
            self.likeButton.setImage(buttonImage, for: .normal)
            //自分がいいねを押している場合は赤いハートマークの画像をセット
        } else {
            let buttonImage = UIImage(named: "like_none")
            self.likeButton.setImage(buttonImage, for: .normal)
            //自分がいいねを押していない場合白抜きハートマークの画像をセットは
        }
        
//(課題用に追加)コメントの追加
        self.commentLabel.text = "\(postData.comment)"
        
    }
    
}
