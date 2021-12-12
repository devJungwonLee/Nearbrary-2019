//
//  LibInfoContentCell.swift
//  Nearbrary
//
//  Created by 이정원 on 17/06/2019.
//  Copyright © 2019 Jungwon Lee. All rights reserved.
//

import UIKit

class LibInfoContentCell: UITableViewCell {
    
    @IBOutlet var location: UILabel!
    @IBOutlet var callno: UILabel!
    @IBOutlet var id: UILabel!
    @IBOutlet var returndate: UILabel!
    @IBOutlet var status: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
