//
//  CafeCommentCell.swift
//  awesomeCnCafe
//
//  Created by Song Zhou on 16/7/31.
//  Copyright © 2016年 Song Zhou. All rights reserved.
//

import UIKit

let cafeCommentCellDefaultCellHeight: CGFloat = 40.0

class CafeCommentCell: UITableViewCell {

    var textView: UITextView!
    
    init(reuseIdentifier: String?) {
        super.init(style: .Default, reuseIdentifier: reuseIdentifier)
        
        self.initTextView()
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .Default, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Init
    func initTextView(){
        textView = UITextView()
        textView.scrollEnabled = false
        textView.editable = false
        textView.font = UIFont.systemFontOfSize(16)
        self.contentView.addSubview(textView)
        
        textView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activateConstraints([
            textView.leadingAnchor.constraintEqualToAnchor(self.contentView.leadingAnchor, constant: Layout.horizontalPadding),
            textView.trailingAnchor.constraintEqualToAnchor(self.contentView.trailingAnchor, constant: -Layout.horizontalPadding),
            textView.topAnchor.constraintEqualToAnchor(self.contentView.topAnchor),
            textView.bottomAnchor.constraintEqualToAnchor(self.bottomAnchor),
            textView.heightAnchor.constraintGreaterThanOrEqualToConstant(cafeCommentCellDefaultCellHeight)
            ])
    }
}

extension CafeCommentCell {
    func setupDataSource(comment: Comment){
        self.textView.text = comment.content
    }
    
    override func prepareForReuse() {
        self.textView.text = nil
    }
}