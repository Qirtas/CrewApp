//
//  Structures.swift
//  Productivity 2
//
//  Created by SPS on 26/02/2018.
//  Copyright © 2018 SPS. All rights reserved.
//

import Foundation
import Mapbox
import GoogleMaps

public struct TracedPath{
    let lineId:Int
    var paths:[[CLLocationCoordinate2D]]
}

public struct CircuitPath{
    let lineId:Int
    let path:[CLLocationCoordinate2D]
    let gmsPath:GMSMutablePath
}
