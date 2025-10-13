//
//  MessageCellCollectionViewCell.swift
//  sekretess
//
//  Created by Elnur Atakishiyev on 11.10.25.
//

import UIKit

class MessageCellCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var  label1: UILabel?
    @IBOutlet weak var  label2: UILabel?
    
    func update(sender: String, messageBrief:String){
        label1?.text = sender
        label2?.text = messageBrief
    }
}
