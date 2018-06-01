//
//  crewRowModel.swift
//  Productivity 2
//
//  Created by SPS on 24/04/2018.
//  Copyright © 2018 SPS. All rights reserved.
//

import Foundation

class CrewRowModel
{
    var crewType: String!
    var totalHours: String!
    var nonProdHours: String!
    
    init(crewType: String , totalHrz: String , nonProdHours: String)
    {
        self.crewType = crewType
        self.totalHours = totalHrz
        self.nonProdHours = nonProdHours
    }
}
