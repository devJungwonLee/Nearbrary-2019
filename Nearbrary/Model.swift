//
//  Model.swift
//  Nearbrary
//
//  Created by Release on 19/05/2019.
//  Copyright © 2019 Jungwon Lee. All rights reserved.
//

import Foundation
import UIKit

class book {
    var title:String?
    var link:String?
    var imageURL:String?
    var image:UIImage?
    var author:String?
    var publisher:String?
    var isbn:String?
    var pubdate:String?
    
    init() {
        
    }
    
    func getBookImage() {
        guard imageURL != nil else {
            return
        }
        if let url = URL(string: imageURL!) {
            if let imgData = try? Data(contentsOf: url) {
                if let image = UIImage(data: imgData) {
                    self.image = image
                }
            }
        }
        return
    }
}
