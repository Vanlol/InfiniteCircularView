//
//  ViewController.swift
//  InfiniteCircular
//
//  Created by admin on 2017/7/13.
//  Copyright © 2017年 admin. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    fileprivate lazy var bannerView:InfiniteCircularView = {
        let vi = InfiniteCircularView(frame: CGRect(x: 0, y: 0, width: 375, height: 200))
        return vi
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(bannerView)
        bannerView.urlStrs = ["sss"]
        bannerView.reloadInfiniteCircularView()
        bannerView.didClickBannerImageClosure = {(vi,index) -> Void in
            print(index)
        }
    }
    
    
    

}

