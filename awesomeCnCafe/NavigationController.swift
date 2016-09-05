//
//  NavigationController.swift
//  awesomeCnCafe
//
//  Created by Song Zhou on 16/9/5.
//  Copyright © 2016年 Song Zhou. All rights reserved.
//

import UIKit
import Motif

class NavigationController: UINavigationController {
    var themeApplier: MTFThemeApplier
    
    init(themeApplier: MTFThemeApplier) {
        self.themeApplier = themeApplier
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        
        do {
            try themeApplier.applyClassWithName(NavigationThemeClassNames.NavigationBar.rawValue, to: self.navigationBar)
        } catch {
            print(error)
        }
    }
}