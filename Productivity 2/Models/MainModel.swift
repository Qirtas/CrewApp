//
//  MainModel.swift
//  Productivity 2
//
//  Created by SPS on 23/02/2018.
//  Copyright © 2018 SPS. All rights reserved.
//

import Foundation

public class MainModel
{
    
    let id:Int!
    let title:String!
    let location:String!
    let startDate:String!
    let endDate:String!
    let description:String?
    
    public var isShowingDescription:Bool = false
    
    init(id:Int , title:String , location:String  ,startDate:String , enddate:String , desc:String?)
    {
        self.id = id
        self.title = title
        self.location = location
        self.startDate = startDate
        self.endDate = enddate
        self.description = desc
    }
    
    
}
