//
//  PlaceCollectionViewCell.swift
//  TravelBook
//
//  Created by Tahir Uzelli on 22.01.2023.
//

import UIKit

class PlaceCollectionViewCell: UICollectionViewCell {
    static let identifier = "PlaceCollectionViewCell"
    
    
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var image: UIImageView!
}
