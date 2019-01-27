//
//  MaxiArticleCardViewController.swift
//  Milli
//
//  Created by Charles Wang on 1/10/19.
//  Copyright © 2019 Milli. All rights reserved.
//

import UIKit

protocol MaxiArticleSourceProtocol: class {
    var originatingFrameInWindow: CGRect { get }
//    var originatingCoverImageView: UIImageView { get }
}

class MaxiArticleCardViewController: UIViewController {
    
    private let tagID = "[MAXI_ARTICLE_CARD_VIEW_CONTROLLER]"
    
    // MARK: - Properties
    var currentArticle: Article?
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
    
    //lower module constraints
    @IBOutlet weak var lowerModuleTopConstraint: NSLayoutConstraint!
    
    //cover image
    @IBOutlet weak var coverImageContainer: UIView!
//    @IBOutlet weak var articleText: UIImageView!
    @IBOutlet var articleText: UITextView!
    @IBOutlet weak var dismissChevron: UIButton!
    
    //cover image constraints
    @IBOutlet weak var articleTextLeading: NSLayoutConstraint!
    @IBOutlet weak var articleTextTop: NSLayoutConstraint!
    @IBOutlet weak var articleTextBottom: NSLayoutConstraint!
    @IBOutlet weak var articleTextHeight: NSLayoutConstraint!
    @IBOutlet weak var articleTextContainerTopInset: NSLayoutConstraint!
    
    weak var sourceView: MaxiArticleSourceProtocol!
    
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
        
        // Load article content into text view
        articleText.text = currentArticle?.content
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureImageLayerInStartPosition()
        stretchySkirt.backgroundColor = .white //from starter project, this hides the gap
        configureLowerModuleInStartPosition()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateBackingImageIn()
        animateImageLayerIn()
        animateLowerModuleIn()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? ArticleSubscriber {
            destination.currentArticle = currentArticle
        }
    }
}

// MARK: - IBActions
extension MaxiArticleCardViewController {
    @IBAction func dismissAction(_ sender: Any) {
        animateBackingImageOut()
//        animateCoverImageOut()
        animateLowerModuleOut()
        animateImageLayerOut() { _ in
            self.dismiss(animated: false)
        }
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

//Image Container animation.
extension MaxiArticleCardViewController {
    
    private var startColor: UIColor {
        return UIColor.white.withAlphaComponent(0.3)
    }
    
    private var endColor: UIColor {
        return .white
    }
    
    //1.
    private var imageLayerInsetForOutPosition: CGFloat {
        let imageFrame = view.convert(sourceView.originatingFrameInWindow, to: view)
        let inset = imageFrame.minY - backingImageEdgeInset
        return inset
    }
    
    //2.
    func configureImageLayerInStartPosition() {
        coverImageContainer.backgroundColor = startColor
        let startInset = imageLayerInsetForOutPosition
        dismissChevron.alpha = 0
        articleText.alpha = 0
        coverImageContainer.layer.cornerRadius = 0
        articleTextContainerTopInset.constant = startInset
        view.layoutIfNeeded()
    }
    
    //3.
    func animateImageLayerIn() {
        //4.
        UIView.animate(withDuration: primaryDuration / 4.0) {
            self.coverImageContainer.backgroundColor = self.endColor
        }
        
        //5.
        UIView.animate(withDuration: primaryDuration, delay: 0, options: [.curveEaseIn], animations: {
            self.articleTextContainerTopInset.constant = 0
            self.dismissChevron.alpha = 1
            self.articleText.alpha = 1
            self.coverImageContainer.layer.cornerRadius = self.cardCornerRadius
            self.view.layoutIfNeeded()
        })
    }
    
    //6.
    func animateImageLayerOut(completion: @escaping ((Bool) -> Void)) {
        let endInset = imageLayerInsetForOutPosition
        
        UIView.animate(withDuration: primaryDuration / 4.0,
                       delay: primaryDuration,
                       options: [.curveEaseOut], animations: {
                        self.coverImageContainer.backgroundColor = self.startColor
        }, completion: { finished in
            completion(finished) //fire complete here , because this is the end of the animation
        })
        
        UIView.animate(withDuration: primaryDuration, delay: 0, options: [.curveEaseOut], animations: {
            self.articleTextContainerTopInset.constant = endInset
            self.dismissChevron.alpha = 0
            self.articleText.alpha = 0
            self.coverImageContainer.layer.cornerRadius = 0
            self.view.layoutIfNeeded()
        })
    }
}

//lower module animation
extension MaxiArticleCardViewController {
    
    //1.
    private var lowerModuleInsetForOutPosition: CGFloat {
        let bounds = view.bounds
        let inset = bounds.height - bounds.width
        return inset
    }
    
    //2.
    func configureLowerModuleInStartPosition() {
        lowerModuleTopConstraint.constant = lowerModuleInsetForOutPosition
    }
    
    //3.
    func animateLowerModule(isPresenting: Bool) {
        let topInset = isPresenting ? 0 : lowerModuleInsetForOutPosition
        UIView.animate(withDuration: primaryDuration,
                       delay:0,
                       options: [.curveEaseIn],
                       animations: {
                        self.lowerModuleTopConstraint.constant = topInset
                        self.view.layoutIfNeeded()
        })
    }
    
    //4.
    func animateLowerModuleOut() {
        animateLowerModule(isPresenting: false)
    }
    
    //5.
    func animateLowerModuleIn() {
        animateLowerModule(isPresenting: true)
    }
}
