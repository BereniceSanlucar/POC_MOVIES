//
//  ExpandableHeaderView.swift
//  ToDoList
//
//  Created by Berenice Mendoza on 1/22/18.
//  Copyright © 2018 berenice. All rights reserved.
//

import UIKit

protocol ExpandableHeaderViewDelegate {
    func toggleSection(header: ExpandableHeaderView, section: Int)
}

class ExpandableHeaderView: UITableViewHeaderFooterView {
    
    var delegate: ExpandableHeaderViewDelegate?
    var section: Int!
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(selectHeaderAction)))
    }
    
    @objc func selectHeaderAction(gestureRecognizer: UITapGestureRecognizer) {
        let cell = gestureRecognizer.view as! ExpandableHeaderView
        delegate?.toggleSection(header: self, section: cell.section)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func customInit(title: String, section: Int, delegate: ExpandableHeaderViewDelegate){
        self.textLabel?.text = title
        self.section = section
        self.delegate = delegate
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.textLabel?.textColor = UIColor.white
        self.contentView.backgroundColor = UIColor(hue: 0.5528, saturation: 0.6, brightness: 0.98, alpha: 1.0)
    }
}
