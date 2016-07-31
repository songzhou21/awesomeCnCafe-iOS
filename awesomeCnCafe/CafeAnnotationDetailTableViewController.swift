//
//  CafeAnnotationDetailTableViewController.swift
//  awesomeCnCafe
//
//  Created by Song Zhou on 16/7/31.
//  Copyright © 2016年 Song Zhou. All rights reserved.
//

import UIKit

let cafe_properties_cell_identifier = "cafe_properties_cell_identifier"
let cafe_comment_cell_identifier = "cafe_comment_cell_identifier"

let cafeCommentCellDefaultCellHeight: CGFloat = 54.5 // two lines
let cafeDetailCellHeight: CGFloat = 40

class CafeAnnotationDetailTableViewController: UITableViewController {
    private let cafe: Cafe
    private var dataSource = [(String, [AnyObject])]()

    init(cafe: Cafe) {
       self.cafe = cafe
        
       super.init(style: .Grouped)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: cafe_properties_cell_identifier)
        
        setUpDataSouce()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return dataSource.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        let section = dataSource[section]
        return section.1.count
    }

    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return dataSource[section].0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let section = dataSource[indexPath.section].1
        var resultCell: UITableViewCell!
        
        let data = section[indexPath.row]
        switch data.dynamicType {
        case is String.Type:
            fallthrough
        case is NSString.Type:
            let cell = tableView.dequeueReusableCellWithIdentifier(cafe_properties_cell_identifier)!
            cell.selectionStyle = .None
        
           cell.textLabel?.text = data as? String
            
            resultCell = cell
        case is CafeCommentCellData.Type:
            var commentCell = tableView.dequeueReusableCellWithIdentifier(cafe_comment_cell_identifier) as? CafeCommentCell
            if commentCell == nil {
                commentCell = CafeCommentCell(reuseIdentifier: cafe_comment_cell_identifier)
            }
            
            if let comment = data as? CafeCommentCellData {
                commentCell?.setupDataSource(comment.data)
                comment.height = commentCell?.textViewHeight()
                
                tableView.beginUpdates()
                tableView.endUpdates()
            }
            
            resultCell = commentCell!
        default: break
        }
        
        return resultCell
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let section = dataSource[indexPath.section].1
        
        let data = section[indexPath.row]
        
        switch data.dynamicType {
        case is CafeCommentCellData.Type:
            let comment = data as! CafeCommentCellData
            if let height = comment.height {
                return height
            } else {
                return cafeCommentCellDefaultCellHeight
            }
        default:
            break
        }
        
        return cafeDetailCellHeight
    }
    
    // MARK: Private
    func setUpDataSouce() {
        if let speeds = cafe.networkSpeed {
            dataSource.append((NSLocalizedString("speed", comment: ""), speeds))
        }
        
        if let comments = cafe.comment {
            dataSource.append(
                (NSLocalizedString("comment", comment: ""),
                    comments.map{ return CafeCommentCellData(comment: $0) })
            )
        }
        
        if let price = cafe.price {
            dataSource.append((NSLocalizedString("price", comment: ""), [price]))
        }
        
        if let properties = cafe.properties {
            let values = properties.keys.map{ key in
                return "\(key):\(properties[key]!)"
            }
            
            dataSource.append((NSLocalizedString("other", comment: ""), Array(values)))
        }
    }
}
