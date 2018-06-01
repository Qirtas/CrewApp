//
//  NoteModel.swift
//  Productivity 2
//
//  Created by SPS on 22/05/2018.
//  Copyright © 2018 SPS. All rights reserved.
//

import Foundation

public struct NoteModel
{
    let id:Int
    let text:String
    let time:String
    let fName:String
    let lName:String
    let lat:Double
    let lng:Double
    
    init(id:Int , text:String , time:String , fName:String , lName:String , lat:Double , lng:Double )
    {
        self.id = id
        self.text = text
        self.time = time
        self.fName = fName
        self.lName = lName
        self.lat = lat
        self.lng = lng
    }
}
