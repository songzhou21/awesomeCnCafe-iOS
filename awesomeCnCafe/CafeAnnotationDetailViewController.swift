//
//  CafeAnnotationDetailViewController.swift
//  awesomeCnCafe
//
//  Created by Song Zhou on 16/7/31.
//  Copyright © 2016年 Song Zhou. All rights reserved.
//

import UIKit

class CafeAnnotationDetailViewController: UIViewController {
    private let cafe: Cafe
    lazy private var tableViewController: CafeAnnotationDetailTableViewController = {
        return CafeAnnotationDetailTableViewController(cafe: self.cafe)
    }()

    init(cafe: Cafe) {
       self.cafe = cafe
        
       super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
       self.title = cafe.name
        
       self.addChildViewController(tableViewController)
       tableViewController.view.frame = self.view.frame
        
       self.view.addSubview(tableViewController.view)
    }
}
