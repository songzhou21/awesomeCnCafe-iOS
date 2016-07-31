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
        
        self.selectionStyle = .None
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
        textView.selectable = false
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
        if let user = comment.author?.userName, let content = comment.content {
            let string = "\(user): \(content)"
            let attributedString = NSMutableAttributedString(string: string)
            let ns_sring = string as NSString
            attributedString.addAttributes([NSForegroundColorAttributeName: UIColor.grayColor()], range: ns_sring.rangeOfString(user))
            attributedString.addAttributes([NSFontAttributeName: UIFont.systemFontOfSize(16)], range: NSMakeRange(0, ns_sring.length))
            
            self.textView.attributedText = attributedString
        }
    }
    
    override func prepareForReuse() {
        self.textView.text = nil
    }
    
    func textViewHeight() -> CGFloat {
        self.layoutIfNeeded()
        let maxSize = CGSize(width: self.textView.bounds.width, height: CGFloat.max)
        return self.textView.sizeThatFits(maxSize).height
    }
}

class CafeCommentCellData {
    var height: CGFloat?
    let data: Comment
    
    init(comment:Comment) {
        data = comment
    }
    
}