//
//  delegates.swift
//  Productivity 2
//
//  Created by SPS on 23/02/2018.
//  Copyright © 2018 SPS. All rights reserved.
//

import Foundation

protocol MainTableCellDelegate:class{
    func updateCell(atIndexPath indexPath:IndexPath)
    func runForward(atIndexPath indexPath:IndexPath)
}
protocol CircuitTableCellDelegate:class{
    func updateCell(atIndexPath indexPath:IndexPath)
    func runForward(atIndexPath indexPath:IndexPath)
}

protocol dragaableAnnotationDelegate:class {
    func isPathTraced(isTraced : Bool)
}
