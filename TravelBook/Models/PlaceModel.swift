//
//  PlaceModel.swift
//  TravelBook
//
//  Created by Tahir Uzelli on 22.01.2023.
//

import Foundation

struct PlaceModel: Codable {
    let id: UUID
    let title, description: String
    let latitude, longitude: Double
    let image: String
    let visitStatus: Int
}

