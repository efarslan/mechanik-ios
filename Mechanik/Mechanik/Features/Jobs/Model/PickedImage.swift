//
//  PickedImage.swift
//  Mechanik
//
//  Created by efe arslan on 30.04.2026.
//

import UIKit

struct PickedImage: Identifiable {
    let id = UUID()
    let data: Data
    let image: UIImage
}
