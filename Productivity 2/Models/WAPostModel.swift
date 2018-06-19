//
//  WAPostModel.swift
//  Productivity 2
//
//  Created by SPS on 13/04/2018.
//  Copyright © 2018 SPS. All rights reserved.
//

import Foundation
import CoreLocation

class WAPostModel
{
    let GFId: Int!
    let WPCircuitID: Int!
    let WAId: Int!
    var note : String!
    var crewInfo: [CrewInfoModel]
    var tracedPaths : [[CLLocationCoordinate2D]]
    var polygons: [[CLLocationCoordinate2D]]
    var isTraceAll : Bool!
    var isNoTrace: Bool!
    var LogDate: String!
    
    init(GFId:Int , WPCId:Int , WAId: Int , note:String , crewInfo: [CrewInfoModel] , tracedPaths: [[CLLocationCoordinate2D]] , polygons:[[CLLocationCoordinate2D]] , isTraceAll:Bool , isNoTrace:Bool , logDate:String)
    {
        self.GFId = GFId
        self.WPCircuitID = WPCId
        self.WAId = WAId
        self.note = note
        self.crewInfo = crewInfo
        self.tracedPaths = tracedPaths
        self.polygons = polygons
        self.isTraceAll = isTraceAll
        self.isNoTrace = isNoTrace
        self.LogDate = logDate
        
    }
    
    func createJson() -> [String:Any]
    {
        var WAPostDictionary = [String:Any]()
        
        WAPostDictionary["GFId"] = GFId
        WAPostDictionary["NoTrace"] = isNoTrace
        WAPostDictionary["TraceAll"] = isTraceAll
        WAPostDictionary["Note"] = note
        WAPostDictionary["WPCircuitId"] = WPCircuitID
        WAPostDictionary["WorkAssignmentId"] = WAId
        WAPostDictionary["LogDate"] = LogDate
        
        var polygonsList = [[[String:Any]]]()
        
        for polygon in polygons
        {
            var polygonDict = [[String:Any]]()
            
            for coordinate in polygon
            {
                var coordinateDictionary = [String: Any]()
                coordinateDictionary["lat"] = coordinate.latitude
                coordinateDictionary["lng"] = coordinate.longitude
                polygonDict.append(coordinateDictionary)
            }
            
            polygonsList.append(polygonDict)
        }

        WAPostDictionary["Polygons"] = polygonsList
        
        print("\(Constants.TAG) tracedpaths size while creating Json \(tracedPaths.count)")
        
        var tracedPathsList = [[[String:Any]]]()
        
        for path in tracedPaths
        {
            var pathDict = [[String:Any]]()
            
            for coordinate in path
            {
                var coordinateDictionary = [String: Any]()
                coordinateDictionary["lat"] = coordinate.latitude
                coordinateDictionary["lng"] = coordinate.longitude
                pathDict.append(coordinateDictionary)
            }
            
            tracedPathsList.append(pathDict)
        }
        
        WAPostDictionary["TracedPaths"] = tracedPathsList
        
        var crewInfoList = [[String:Any]]()
        
        
        for crewType in crewInfo
        {
            var crewInfoDict = [String:Any]()
            crewInfoDict["CrewTypeId"] = crewType.crewTypeID
            crewInfoDict["Hours"] = crewType.hours
            crewInfoDict["NonProdHours"] = crewType.nonProdHours
            
            crewInfoList.append(crewInfoDict)
        }
        
        WAPostDictionary["CrewInfo"] = crewInfoList
        
        return WAPostDictionary
        
    }
   
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}
