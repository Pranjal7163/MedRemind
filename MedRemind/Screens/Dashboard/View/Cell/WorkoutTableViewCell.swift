//
//  WorkoutTableViewCell.swift
//  MedRemind
//
//  Created by Pranjal Vyas on 02/03/22.
//

import UIKit

class WorkoutTableViewCell: UITableViewCell {
    @IBOutlet weak var thumbnailImage: UIImageView!
    
    @IBOutlet weak var workoutName: UILabel!
    
    @IBOutlet weak var watchButton: UIButton!
    
    @IBOutlet weak var doneIcon: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
