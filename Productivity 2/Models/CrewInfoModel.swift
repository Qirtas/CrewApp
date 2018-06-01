//
//  CrewInfoModel.swift
//  Productivity 2
//
//  Created by SPS on 13/04/2018.
//  Copyright © 2018 SPS. All rights reserved.
//

import Foundation

class CrewInfoModel
{
    var crewTypeID: Int!
    var hours: Float!
    var nonProdHours: Float!
    
    init(crewTypeId:Int , hours:Float , nonProdHours:Float)
    {
        self.crewTypeID = crewTypeId
        self.hours = hours
        self.nonProdHours = nonProdHours
        
    }
}
