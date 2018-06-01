//
//  CircuitTableViewCell.swift
//  Productivity 2
//
//  Created by SPS on 24/02/2018.
//  Copyright © 2018 SPS. All rights reserved.
//

import UIKit

class CircuitTableViewCell: UITableViewCell {

    @IBOutlet weak var viewTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var statusView: UIView!
//    @IBOutlet weak var descriptionView: UIView!
    
    @IBOutlet weak var totalHoursLabel: UILabel!
    
    @IBOutlet weak var milagelabel: UILabel!
    @IBOutlet weak var nonProdHoursLabel: UILabel!
    @IBOutlet weak var startLabel: UILabel!
    @IBOutlet weak var endLabel: UILabel!
    
//    @IBOutlet weak var showHeightConstraint: NSLayoutConstraint!
//    @IBOutlet weak var descriptionBottomConstraint: NSLayoutConstraint!
//    @IBOutlet weak var descriptionTopToContentBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var contentBottomConstraint: NSLayoutConstraint!
    
    var delegate:CircuitTableCellDelegate?
    var indexPath:IndexPath?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        
        let tapGesture:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(inDescTapped(recognizer:)))
//        descriptionView.addGestureRecognizer(tapGesture)
        
    }
    
    @IBAction func startButtonTapped(_ sender: Any) {
        delegate?.runForward(atIndexPath: indexPath!)
    }
    
    @objc func inDescTapped(recognizer:UITapGestureRecognizer){
        delegate?.updateCell(atIndexPath: indexPath!)
    }
    @IBAction func showButtonTapped(_ sender: Any) {
        delegate?.updateCell(atIndexPath: indexPath!)
    }
    
//    func showDescription(){
//        descriptionView.isHidden = false
//
//        showHeightConstraint.constant = 0
//        descriptionTopToContentBottomConstraint.priority = UILayoutPriority(999)
//        descriptionBottomConstraint.priority = UILayoutPriority(999)
//        contentBottomConstraint.priority = UILayoutPriority(500)
//    }
    
//    func hideDescription(){
//        descriptionView.isHidden = true
//        
//        showHeightConstraint.constant = CGFloat(Constants.circuitTableShowButtonHeight)
//        descriptionTopToContentBottomConstraint.priority = UILayoutPriority(500)
//        descriptionBottomConstraint.priority = UILayoutPriority(500)
//        contentBottomConstraint.priority = UILayoutPriority(999)
//    }
    
}
