//
//  LineModel.swift
//  Productivity 2
//
//  Created by SPS on 10/04/2018.
//  Copyright © 2018 SPS. All rights reserved.
//

import Foundation

public struct LineModel
{
    let Id: Int
    let Path: [PointModel]
    
    init(id:Int , path:[PointModel]) {
        self.Id = id
        self.Path = path
    }
}
