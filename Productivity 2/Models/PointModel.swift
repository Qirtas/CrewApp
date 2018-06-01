//
//  PointModel.swift
//  Productivity 2
//
//  Created by SPS on 10/04/2018.
//  Copyright © 2018 SPS. All rights reserved.
//

import Foundation

public struct PointModel
{
    let lat:Double!
    let lng:Double!
    
    init(lat:Double , lng:Double) {
        self.lat = lat
        self.lng = lng
    }
}
