//
//  MaxiArticleCardViewController.swift
//  Milli
//
//  Created by Charles Wang on 1/10/19.
//  Copyright © 2019 Milli. All rights reserved.
//

import UIKit

class MaxiArticleCardViewController: UIViewController {
    
    private let tagID = "[MAXI_ARTICLE_CARD_VIEW_CONTROLLER]"
    
    // MARK: - Properties
    let cardCornerRadius: CGFloat = 10
    let primaryDuration = 4.0 //set to 0.5 when ready
    let backingImageEdgeInset: CGFloat = 15.0
    
    //scroller
    @IBOutlet var scrollView: UIScrollView!
    //this gets colored white to hide the background.
    //It has no height so doesnt contribute to the scrollview content
    @IBOutlet weak var stretchySkirt: UIView!
    
    //backing image
    var backingImage: UIImage?
    @IBOutlet var backingImageView: UIImageView!
    @IBOutlet var dimmerLayer: UIView!
    //backing image constraints
    @IBOutlet weak var backingImageTopInset: NSLayoutConstraint!
    @IBOutlet weak var backingImageLeadingInset: NSLayoutConstraint!
    @IBOutlet weak var backingImageTrailingInset: NSLayoutConstraint!
    @IBOutlet weak var backingImageBottomInset: NSLayoutConstraint!
    
    //cover image
    @IBOutlet weak var coverImageContainer: UIView!
    @IBOutlet weak var coverArtImage: UIImageView!
    @IBOutlet weak var dismissChevron: UIButton!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - View Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        
        modalPresentationCapturesStatusBarAppearance = true //allow this VC to control the status bar appearance
        modalPresentationStyle = .overFullScreen //dont dismiss the presenting view controller when presented
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        backingImageView.image = backingImage
        
        scrollView.contentInsetAdjustmentBehavior = .never //dont let Safe Area insets affect the scroll view
        
        //DELETE THIS LATER
//        scrollView.isHidden = true
        
        coverImageContainer.layer.cornerRadius = cardCornerRadius
        coverImageContainer.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateBackingImageIn()
    }
}

// MARK: - IBActions
extension MaxiArticleCardViewController {
    @IBAction func dismissAction(_ sender: Any) {
        
    }
}

//background image animation
extension MaxiArticleCardViewController {
    
    //1.
    private func configureBackingImageInPosition(presenting: Bool) {
        let edgeInset: CGFloat = presenting ? backingImageEdgeInset : 0
        let dimmerAlpha: CGFloat = presenting ? 0.3 : 0
        let cornerRadius: CGFloat = presenting ? cardCornerRadius : 0
        
        backingImageLeadingInset.constant = edgeInset
        backingImageTrailingInset.constant = edgeInset
        let aspectRatio = backingImageView.frame.height / backingImageView.frame.width
        backingImageTopInset.constant = edgeInset * aspectRatio
        backingImageBottomInset.constant = edgeInset * aspectRatio
        //2.
        dimmerLayer.alpha = dimmerAlpha
        //3.
        print_debug(tagID, message: "cornerRadius: \(cornerRadius)")
        backingImageView.layer.cornerRadius = cornerRadius
    }
    
    //4.
    private func animateBackingImage(presenting: Bool) {
        UIView.animate(withDuration: primaryDuration) {
            self.configureBackingImageInPosition(presenting: presenting)
            self.view.layoutIfNeeded() //IMPORTANT!
        }
    }
    
    //5.
    func animateBackingImageIn() {
        animateBackingImage(presenting: true)
    }
    
    func animateBackingImageOut() {
        animateBackingImage(presenting: false)
    }
}
