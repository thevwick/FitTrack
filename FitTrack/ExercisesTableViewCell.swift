//
//  ExercisesTableViewCell.swift
//  FitTrack
//
//  Created by Ash  on 17/6/19.
//  Copyright © 2019 Thev. All rights reserved.
//

import UIKit

class ExercisesTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var weightLabel: UILabel!
    @IBOutlet weak var repsLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
