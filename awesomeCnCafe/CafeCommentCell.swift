//
//  CafeCommentCell.swift
//  awesomeCnCafe
//
//  Created by Song Zhou on 16/7/31.
//  Copyright © 2016年 Song Zhou. All rights reserved.
//

import UIKit

class CafeCommentCell: UITableViewCell {

    var textView: UITextView!
    
    init(reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        
        self.selectionStyle = .none
        self.initTextView()
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Init
    func initTextView(){
        textView = UITextView()
        textView.isScrollEnabled = false
        textView.isEditable = false
        textView.isSelectable = false
        self.contentView.addSubview(textView)
        
        textView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            textView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: Layout.horizontalPadding),
            textView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -Layout.horizontalPadding),
            textView.topAnchor.constraint(equalTo: self.contentView.topAnchor),
            textView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            textView.heightAnchor.constraint(greaterThanOrEqualToConstant: cafeCommentCellDefaultCellHeight)
            ])
    }
}

extension CafeCommentCell {
    func setupDataSource(_ comment: Comment){
        if let user = comment.author?.userName, let content = comment.content {
            let string = "\(user): \(content)"
            let attributedString = NSMutableAttributedString(string: string)
            let ns_sring = string as NSString
            attributedString.addAttributes([NSForegroundColorAttributeName: UIColor.gray], range: ns_sring.range(of: user))
            attributedString.addAttributes([NSFontAttributeName: UIFont.systemFont(ofSize: 16)], range: NSMakeRange(0, ns_sring.length))
            
            self.textView.attributedText = attributedString
        }
    }
    
    override func prepareForReuse() {
        self.textView.text = nil
    }
    
    func textViewHeight() -> CGFloat {
        self.layoutIfNeeded()
        
        let maxSize = CGSize(width: self.textView.bounds.width, height: CGFloat.greatestFiniteMagnitude)
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
