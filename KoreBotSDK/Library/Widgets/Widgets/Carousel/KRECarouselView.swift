//
//  KRECarouselView.swift
//  Widgets
//
//  Created by anoop on 24/05/17.
//
//

import UIKit

public class KRECarouselView: UICollectionView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate {
    
    static public let cardPadding: CGFloat = 10.0
    static public let cardLimit: Int = 10
    public var maxCardHeight: CGFloat = 0.0
    public var maxCardWidth: CGFloat = 0.0
    public var numberOfItems: Int = 0
    
    public var cards: Array<KRECardInfo> = Array<KRECardInfo>() {
        didSet {
            self.numberOfItems = min(cards.count, KRECarouselView.cardLimit)
            
            var maxHeight: CGFloat = 0.0
            for i in 0..<self.numberOfItems {
                let cardInfo = cards[i]
                let height = KRECardView.getExpectedHeight(cardInfo: cardInfo, width: maxCardWidth - KRECarouselView.cardPadding)
                if(height > maxHeight){
                    maxHeight = height
                }
            }
            self.maxCardHeight = maxHeight
            self.reloadData()
        }
    }
    
    public var optionsAction: ((_ text: String?) -> Void)!
    public var linkAction: ((_ text: String?) -> Void)!
    
    public override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
    }
    
    convenience init () {
        var flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = UICollectionViewScrollDirection.horizontal
        flowLayout.minimumInteritemSpacing = 10.0
        flowLayout.minimumLineSpacing = 10.0
        flowLayout.sectionInset = UIEdgeInsetsMake(0.0, 45.0, 0.0, 45.0)
        
        self.init(frame: CGRect.zero, collectionViewLayout: flowLayout)
        self.backgroundColor = UIColor.clear
        self.clipsToBounds = false
        self.bounces = true
        self.showsHorizontalScrollIndicator = false
        self.showsVerticalScrollIndicator = false
        self.dataSource = self
        self.delegate = self
        
        self.register(KRECardCollectionViewCell.self, forCellWithReuseIdentifier: KRECardCollectionViewCell.cellReuseIdentifier)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK:- datasource
    public func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.numberOfItems
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: KRECardCollectionViewCell.cellReuseIdentifier, for: indexPath) as! KRECardCollectionViewCell
        let cardInfo = cards[indexPath.row]
        cell.cardView.configureForCardInfo(cardInfo: cardInfo)
        
        if(indexPath.row == 0){
            cell.cardView.isFirst = true
        }else{
            cell.cardView.isFirst = false
        }
        if(indexPath.row == self.numberOfItems-1){
            cell.cardView.isLast = true
        }else{
            cell.cardView.isLast = false
        }
        cell.cardView.optionsAction = {[weak self] (text) in
            if((self?.optionsAction) != nil){
                self?.optionsAction(text)
            }
        }
        cell.cardView.linkAction = {[weak self] (text) in
            if(self?.linkAction != nil){
                self?.linkAction(text)
            }
        }
        
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let cardCell = cell as! KRECardCollectionViewCell
        cardCell.cardView.updateLayer()
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cardInfo = cards[indexPath.row]
        if(cardInfo.defaultActionInfo != nil){
            let defaultActionInfo:Dictionary<String,String>? = cardInfo.defaultActionInfo
            if (defaultActionInfo?["type"] == "web_url") {
                if ((self.linkAction) != nil) {
                    self.linkAction(defaultActionInfo?["url"])
                }
            } else if (defaultActionInfo?["type"] == "postback") {
                if (self.optionsAction != nil) {
                    self.optionsAction(defaultActionInfo?["payload"])
                }
            }
        }
    }
    
    // MARK: - UICollectionViewDelegateContactFlowLayout
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: maxCardWidth, height: maxCardHeight)
    }
    
    public func prepareForReuse() {
        self.cards.removeAll()
    }
    
    // MARK:- Scroll view delegate
    public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        // Ensure the scrollview is the one on the collectionView we care are working with
        if (scrollView == self) {
            
            // Find cell closest to the frame centre with reference from the targetContentOffset
            let frameCenter: CGPoint = self.center
            var targetOffsetToCenter: CGPoint = CGPoint(x: self.contentOffset.x + frameCenter.x, y: self.contentOffset.y + frameCenter.y)
            var currentIndexPath: IndexPath? = self.indexPathForItem(at: targetOffsetToCenter)
            
            // Check for "edge case" where the target will land right between cells and then next neighbor to prevent scrolling to index {0,0}.
            while currentIndexPath == nil {
                targetOffsetToCenter.x += 10
                currentIndexPath = self.indexPathForItem(at: targetOffsetToCenter)
            }
            // safe unwrap to make sure we found a valid index path
            if let index = currentIndexPath {
                var newPage = Float(index.row)
                let pageWidth = Float(maxCardWidth + 10.0)
                let targetXContentOffset = Float(targetContentOffset.pointee.x)
                let contentWidth = Float(self.contentSize.width)
                
                if velocity.x == 0 {
                    newPage = floor( (targetXContentOffset - Float(pageWidth) / 2) / Float(pageWidth)) + 1.0
                } else {
                    newPage = Float(velocity.x > 0 ? newPage + 1 : newPage - 1)
                    if newPage < 0 {
                        newPage = 0
                    }
                    if (newPage > contentWidth / pageWidth) {
                        newPage = ceil(contentWidth / pageWidth) - 1.0
                    }
                }
                let point = CGPoint (x: CGFloat(newPage * pageWidth), y: targetContentOffset.pointee.y)
                targetContentOffset.pointee = point
            }
        }
    }
}