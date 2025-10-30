//
//  MessagesViewController.swift
//  sekretess
//
//  Created by Elnur Atakishiyev on 11.10.25.
//

import UIKit
import SwiftData

private let reuseIdentifier = "MessageCell"

class MessagesCollectionViewController: UICollectionViewController{
    
    var messages :[MessageBriefDto] = [
        MessageBriefDto(sender:"Amazon", messageBrief: "your order is delivering to ..."),
        MessageBriefDto(sender: "GreenCard", messageBrief: "Congratulations you are ...")
    ]
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
//        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return messages.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? MessageCellCollectionViewCell else {
            fatalError("Incorrect cell type")
        }
        
        let messagDto = messages[indexPath.item]
        // Configure the cell
        cell.update(sender: messagDto.sender, messageBrief: messagDto.messageBrief)
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Cell clicked " , messages[indexPath.item])
        let delegate = UIApplication.shared.delegate as! AppDelegate
        delegate.database?.clearKeys()
    }

}

