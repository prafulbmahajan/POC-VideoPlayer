//
//  VideoCell.swift
//  VideoPlayer
//
//  Created by Praful Mahajan on 25/05/20.
//  Copyright © 2020 prafulmahajan. All rights reserved.
//

import UIKit

class VideoCell: UITableViewCell {

    @IBOutlet weak var videoName: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    static func cellIdentifier() -> String {
        return "VideoCell"
    }

}
