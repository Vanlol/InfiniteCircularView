//
//  InfiniteCircularView.swift
//  SwiftCocoa
//
//  Created by admin on 2017/7/12.
//  Copyright © 2017年 admin. All rights reserved.
//

import UIKit
//import SDWebImage

class InfiniteCircularView: UIView {
    //MARK: 点击回调的闭包
    var didClickBannerImageClosure:((InfiniteCircularView,Int) -> Void)?
    //MARK: 一共有多少个区
    fileprivate let totalSections = 1000
    //MARK: 定时器
    fileprivate var timer:Timer!
    //MARK: banner,url字符串数组
    lazy var urlStrs = [String]()
    //MARK: 轮播滑动视图
    fileprivate lazy var contentCollectionView:UICollectionView = {
        let vi = UICollectionView(frame: self.bounds, collectionViewLayout: CustomFlowLayout())
        vi.register(CustomCollectionViewCell.self, forCellWithReuseIdentifier: "CustomCollectionViewCellID")
        vi.isScrollEnabled = false
        vi.delegate = self
        vi.dataSource = self
        return vi
    }()
    //MARK: pageControl页码指示器
    fileprivate lazy var pageControl:UIPageControl = {
        let pc = UIPageControl()
        pc.bounds = CGRect(x: 0, y: 0, width: 200, height: 20)
        pc.center = CGPoint(x: self.bounds.size.width * 0.5, y: self.bounds.size.height - 10)
        pc.pageIndicatorTintColor = UIColor.lightGray
        pc.currentPageIndicatorTintColor = UIColor.white
        pc.numberOfPages = 0
        return pc
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initView()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        initView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    //MARK: 刷新banner的方法
    func reloadInfiniteCircularView() {
        if urlStrs.count <= 1 {
            contentCollectionView.reloadData()
            contentCollectionView.isScrollEnabled = false
            pageControl.numberOfPages = urlStrs.count
            pageControl.currentPageIndicatorTintColor = UIColor.clear
            stopTimer()
        }else{
            stopTimer()
            contentCollectionView.reloadData()
            contentCollectionView.scrollToItem(at: IndexPath(item: 0, section: totalSections/2), at: .left, animated: false)
            contentCollectionView.isScrollEnabled = true
            pageControl.numberOfPages = urlStrs.count
            pageControl.currentPageIndicatorTintColor = UIColor.white
            startTimer()
        }
    }
    //MARK: 初始化View
    fileprivate func initView(){
        addSubview(contentCollectionView)
        addSubview(pageControl)
    }
    //MARK: 开启定时器
    fileprivate func startTimer() {
        let time = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(nextPage), userInfo: nil, repeats: true)
        RunLoop.main.add(time, forMode: .commonModes)
        timer = time
    }
    //MARK: 关闭定时器
    fileprivate func stopTimer() {
        if timer == nil { return }
        timer.invalidate()
        timer = nil
    }
    //MARK: 定时器方法
    @objc fileprivate func nextPage() {
        let currentIndexPath = contentCollectionView.indexPathsForVisibleItems.last!
        let currentIndexPathReset = IndexPath(item: currentIndexPath.item, section: totalSections/2)
        contentCollectionView.scrollToItem(at: currentIndexPathReset, at: .left, animated: false)
        var nextItem = currentIndexPathReset.item + 1
        var nextSection = currentIndexPathReset.section
        if nextItem == urlStrs.count {
            nextItem = 0
            nextSection += 1
        }
        let nextIndexPath = IndexPath(item: nextItem, section: nextSection)
        contentCollectionView.scrollToItem(at: nextIndexPath, at: .left, animated: true)
    }
}

extension InfiniteCircularView:UICollectionViewDataSource,UICollectionViewDelegate {
    //MARK: UICollectionViewDataSource
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return totalSections
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return urlStrs.count == 0 ? 1 : urlStrs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CustomCollectionViewCellID", for: indexPath) as! CustomCollectionViewCell
        
        if urlStrs.count == 0 {
            cell.conImageView.image = UIImage(named: "default-banner")
        }else{
            let urlStr = urlStrs[indexPath.item]
            let url = URL(string: urlStr)
            if url == nil {
                cell.conImageView.image = UIImage(named: "default-banner")
            }else{
                cell.conImageView.image = UIImage(named: "img_0" + "\(indexPath.item)")
                //cell.conImageView.sd_setImage(with: url!, placeholderImage: UIImage(named: "default-banner")!)
            }
        }
        
        return cell
    }
    //MARK: UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if urlStrs.count == 0 { return }
        didClickBannerImageClosure?(self,indexPath.item)
    }
    //MARK: UIScrollViewDelegate
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        stopTimer()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        startTimer()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let page = Int((scrollView.contentOffset.x/scrollView.frame.size.width+0.5).truncatingRemainder(dividingBy: (CGFloat)(urlStrs.count)))
        pageControl.currentPage = page
    }
}

class CustomFlowLayout: UICollectionViewFlowLayout {
    override func prepare() {
        super.prepare()
        minimumInteritemSpacing = 0
        minimumLineSpacing = 0
        scrollDirection = .horizontal
        itemSize = CGSize(width: (collectionView?.bounds.size.width)!, height: (collectionView?.bounds.size.height)!)
        collectionView?.showsVerticalScrollIndicator = false
        collectionView?.showsHorizontalScrollIndicator = false
        collectionView?.isPagingEnabled = true
        collectionView?.backgroundColor = UIColor.clear
    }
}

class CustomCollectionViewCell: UICollectionViewCell {
    //MARK: bannerImageView
    fileprivate lazy var conImageView:UIImageView = {
        let vi = UIImageView(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
        return vi
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    //MARK: 初始化视图
    fileprivate func initView() {
        backgroundColor = UIColor.clear
        addSubview(conImageView)
    }
    
}
