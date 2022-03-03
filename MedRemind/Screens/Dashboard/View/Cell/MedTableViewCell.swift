//
//  MedTableViewCell.swift
//  MedRemind
//
//  Created by Pranjal Vyas on 02/03/22.
//

import UIKit

class MedTableViewCell: UITableViewCell {
    @IBOutlet weak var drugName: UILabel!
    @IBOutlet weak var drugIcon: UIImageView!
    @IBOutlet weak var drugDose: UILabel!
    @IBOutlet weak var drugFoodContextStackView: UIStackView!
    @IBOutlet weak var drugFoodContext: UILabel!
    @IBOutlet weak var doneImage: UIImageView!
    @IBOutlet weak var takeButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
