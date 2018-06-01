//
//  Constants.swift
//  Productivity 2
//
//  Created by SPS on 23/02/2018.
//  Copyright © 2018 SPS. All rights reserved.
//

import Foundation
import Mapbox


public class Constants{
    static public let firstConstant:String = "constant"
    static public let TAG:String = "crewApp"

    
    static public let mainTableCellIdentifier = "mainTableCell"
    static public let circuitTableCellIdentifier = "circuitTableCell"
    
    static public let segueMainToCircuitIdentifier = "showCircuits"
    static public let segueCircuitToMapIdentifier = "showMap"
    static public let segueCircuitToTracingIdentifier = "showTracingScreen"
    static public let segueTracingToAddHoursIdentifier = "showAddHoursScreen"
    static public let segueshowAddHoursToCircuitIdentifier = "showAddHoursToCircuit"

    static public let segueMapToAddHoursIdentifier = "showAddHours"
    
    static public let segueShowAddHoursScreenIdentifier = "showAddHoursScreeen"
    static public let segueOpenAddHoursScreenIdentifier = "openAddHoursScreen"
    
    static public let segueShowWorkPlansIdentifier = "showWorkPlansIdentifier"

    static public let annotation_polygon_dot = "annotationPolygonDot"
    static public let annotation_polygon_line = "annotationPolygonLine"
    static public let annotation_polygon = "annotationPolygon"
    static public let annotation_tracd_line = "annotationTracedLine"


    static public let annotation_dragable_view = "To drag this annotation, first tap and hold."
    
    static public let assignmentSubmitSuccessful = "Assignment submited successfully"
    
    static public let remainingPath = "remainingPath"
    static public let donePath = "donePath"
    static public let WPId = "workPlanID"
    static public let isAllPathMode = "isAllPathMode"
    static public let isNoTrace = "isNoTrace"
    
    static public let circuitFullObj = "circuitFullObj"
    static public let notesList = "notesList"

    
    static public let noteMarker = "note_marker"


    static public var isCrewOpned = false
    static public var isHoursFieldActive = false

    static public var UserID = 1

    static public let WorkAssignmentId = "workAssignmentId"

    static public let WPCircuitID = "wpCircuitID"
    static public let polygonsList = "polygonsList"
static public let tracedPathsList = "tracedPathsList"
    
    static public let MainTableShowButtonWidth = 18
    static public let circuitTableShowButtonHeight = 18
    
    static public let ok = "Ok"
    
    static public let noWorkplansFound = "No Work plans found."
    static public let noCircuitsFound = "No circuits found."
    static public let genericError = "Data retrieval failedl"
    
    
    static func doLineSegmentsIntersect(p:CLLocationCoordinate2D , p2:CLLocationCoordinate2D , q:CLLocationCoordinate2D , q2:CLLocationCoordinate2D) -> Bool
    {
        print("doLineSegmentsIntersect P: \(p) p2: \(p2) q: \(q) q2: \(q2)")
        
        let r:CLLocationCoordinate2D = subtractPoints(point1: p2, point2: p)
        let s:CLLocationCoordinate2D = subtractPoints(point1: q2, point2: q)
        
        print("R: \(r)" )
        print("S: \(s)" )
        
        print("QPSub: \(subtractPoints(point1: q, point2: p))" )
        
        let uNumerator = crossProduct(point1: subtractPoints(point1: q, point2: p), point2: r)
        let denominator = crossProduct(point1: r, point2: s)
        
        print("uNumerator: \(uNumerator)" )
        print("denominator: \(denominator)" )
        
        if(uNumerator == 0 && denominator == 0)
        {
            print("%%%%%%%%%")
            
            if(equalPoints(point1: p, point2: q) || equalPoints(point1: p, point2: q2) || equalPoints(point1: p2, point2: q) || equalPoints(point1: p2, point2: q2))
            {
                print("*********")
                return false
            }
            
            var arrayLong:[Bool] = [Bool]()
            arrayLong[0] = q.longitude - p.longitude < 0
            arrayLong[1] = q.longitude - p2.longitude < 0
            arrayLong[2] = q2.longitude - p.longitude < 0
            arrayLong[3] = q2.longitude - p2.longitude < 0
            
            var arrayLat:[Bool] = [Bool]()
            arrayLat[0] = q.latitude - p.latitude < 0
            arrayLat[1] = q.latitude - p2.latitude < 0
            arrayLat[2] = q2.latitude - p.latitude < 0
            arrayLat[3] = q2.latitude - p2.latitude < 0
            
            return !allEqual(args: arrayLong) || !allEqual(args: arrayLat)

        }
        
        if(denominator == 0)
        {
            print("(((((((")
            return false
        }
        
        print("------")
        
        let u:Double = uNumerator / denominator
        let t:Double = crossProduct(point1: subtractPoints(point1: q, point2: p), point2: s) / denominator
        
        print("U \(u)")
        print("T \(t)")
        
        return (t >= 0) && (t <= 1) && (u >= 0) && (u <= 1)

    }
    
    static func subtractPoints(point1:CLLocationCoordinate2D , point2:CLLocationCoordinate2D) -> CLLocationCoordinate2D
    {
        var result:CLLocationCoordinate2D = CLLocationCoordinate2D();
        result.latitude = point1.latitude - point2.latitude
        result.longitude = point1.longitude - point2.longitude
        return result
    }
    
    static func crossProduct(point1:CLLocationCoordinate2D , point2:CLLocationCoordinate2D)-> Double
    {
        return (point1.longitude * point2.latitude) - (point1.latitude * point2.longitude)
    }
    
    static func equalPoints(point1:CLLocationCoordinate2D , point2:CLLocationCoordinate2D)-> Bool
    {
        return (point1.longitude == point2.longitude) && (point1.latitude == point2.latitude)
    }
    
    static func allEqual(args : [Bool]) -> Bool
    {
        let firstValue = args[0]
        
        for arg in args
        {
            if(arg != firstValue)
            {
                return false
            }
        }
        
        return true
    }
    
}
















