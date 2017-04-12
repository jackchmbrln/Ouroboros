//
//  OULoadingTableViewCell.swift
//  Ouroboros
//
//  Created by Jack Chamberlain on 16/10/2016.
//  Copyright © 2016 Jack Chamberlain. All rights reserved.
//

import UIKit

public class OULoadingTableViewCell: UITableViewCell {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.activityIndicator.startAnimating()
    }

    override public func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
