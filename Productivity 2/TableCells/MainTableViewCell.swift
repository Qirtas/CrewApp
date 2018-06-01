//
//  TableViewCell.swift
//  Productivity 2
//
//  Created by SPS on 23/02/2018.
//  Copyright © 2018 SPS. All rights reserved.
//

import UIKit

class MainTableViewCell: UITableViewCell {

    @IBOutlet weak var mainView: UIView!
    
    @IBOutlet weak var showButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var endTimeLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var descriptionView: UIView!
    @IBOutlet weak var descriptionTextLabel: UILabel!
    
    @IBOutlet weak var cellTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var showWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var descriptionBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var contentBottomConstraint: NSLayoutConstraint!
//    @IBOutlet weak var contentBottomdescriptionTopConstraint: NSLayoutConstraint!
    
    var delegate:MainTableCellDelegate?
    var indexPath:IndexPath?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        
        let tapDescGesture = UITapGestureRecognizer(target: self, action: #selector(tapDescFunction(sender:)))
        descriptionView.addGestureRecognizer(tapDescGesture)
        
        let tapLocGesture = UITapGestureRecognizer(target: self, action: #selector(tapLocFunction(sender:)))
        locationLabel.addGestureRecognizer(tapLocGesture)
        locationLabel.isUserInteractionEnabled = true
    }
    
    @IBAction func showCircuits(_ sender: Any) {
        delegate?.runForward(atIndexPath: indexPath!)
    }
    @objc func tapDescFunction(sender:UITapGestureRecognizer) {
        delegate?.updateCell(atIndexPath: indexPath!)
    }
    
    @objc func tapLocFunction(sender:UITapGestureRecognizer) {
        delegate?.updateCell(atIndexPath: indexPath!)
    }

    @IBAction func showButtonPressed(_ sender: Any) {
        delegate?.updateCell(atIndexPath: indexPath!)
    }
    @IBAction func hideButtonPressed(_ sender: Any) {
       delegate?.updateCell(atIndexPath: indexPath!)
    }
    
    func showDescription(){
        showWidthConstraint.constant = 0
        showButton.isHidden = true
        
        descriptionView.isHidden = false
        descriptionBottomConstraint.priority = UILayoutPriority(999)
        contentBottomConstraint.priority = UILayoutPriority(500)
//        contentBottomdescriptionTopConstraint.priority = UILayoutPriority(999)
        
    }
    
    func hideDescription(){
        showWidthConstraint.constant = CGFloat(Constants.MainTableShowButtonWidth)
        showButton.isHidden = false
        
        descriptionView.isHidden = true
        descriptionBottomConstraint.priority = UILayoutPriority(500)
        contentBottomConstraint.priority = UILayoutPriority(999)
//        contentBottomdescriptionTopConstraint.priority = UILayoutPriority(500)
        
    }
}
