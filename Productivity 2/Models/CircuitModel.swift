//
//  CircuitModel.swift
//  Productivity 2
//
//  Created by SPS on 24/02/2018.
//  Copyright © 2018 SPS. All rights reserved.
//

import Foundation

public struct CircuitModel{
    
    let id:Int!
    let title:String!
    let startDate:String!
    let endDate:String!
    let hours:String!
    let nonProdHours:String!
    let mileage:String!
    let statusName:String!
    let statusColor:String!
    let workAssignmentID:Int!
    let WPCircuitID:Int!
    
    let remainingPath:[LineModel]
    let donePath:[LineModel]
    
    var isShowingDescription = false
    let circuitFullObj:[String:Any]
    let notesList:[NoteModel]

    
    init(id:Int , title:String , startDate:String , endDate:String , hours:String , mileage:String , statusName:String , statusColor:String , remainingPath:[LineModel] , donePath:[LineModel] , workAssignmentID:Int , workPlanCircuitID:Int , circuitFullObj:[String:Any] , nonProdHours:String , notesList:[NoteModel])
    {
        self.id = id;
        self.title = title;
        self.startDate = startDate;
        self.endDate = endDate;
        self.hours = hours;
        self.mileage = mileage
        self.statusName = statusName
        self.statusColor = statusColor
        self.remainingPath = remainingPath;
        self.donePath = donePath;
        self.workAssignmentID = workAssignmentID
        self.WPCircuitID = workPlanCircuitID
        self.circuitFullObj = circuitFullObj
        self.nonProdHours = nonProdHours
        self.notesList = notesList
    }
    
}
