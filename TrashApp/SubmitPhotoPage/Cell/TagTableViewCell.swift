//
//  TagTableViewCell.swift
//  TrashApp
//
//  Created by Volodymyr Nazarkevych on 04.07.2022.
//

import UIKit

class TagTableViewCell: UITableViewCell {
    @IBOutlet private weak var title: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configure(text: String) {
        title.text = text
    }
    
}
