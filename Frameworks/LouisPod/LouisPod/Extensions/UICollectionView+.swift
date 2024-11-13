//
//  UICollectionView.swift
//  BaseProject
//
//  Created by nguyen.viet.luy on 7/17/20.
//  Copyright © 2020 nguyen.viet.luy. All rights reserved.
//

import UIKit
import SVPullToRefresh

// MARK: - SVPullToRefresh+
extension UICollectionView {
    public func addPullToRefresh(completion: (() -> Void)?) {
        addPullToRefresh(actionHandler: completion)
    }
    
    public func hasMorePage(_ hasMorePage: Bool) {
        showsInfiniteScrolling = hasMorePage
    }
    
    public func removeLoadingMore() {
        showsInfiniteScrolling = false
    }
    
    public func removePullToRefresh() {
        showsPullToRefresh = false
    }
    
    public func addLoadingMore(completion: (() -> Void)?) {
        addInfiniteScrolling(actionHandler: completion)
    }
    
    public func isRefreshing(_ isRefreshing: Bool) {
        isRefreshing
        ? pullToRefreshView.startAnimating()
        : pullToRefreshView.stopAnimating()
    }
    
    public func isLoadingMore(_ isLoadingMore: Bool) {
        isLoadingMore
        ? infiniteScrollingView.startAnimating()
        : infiniteScrollingView.stopAnimating()
    }
}

// MARK: - Functions
extension UICollectionView {
//    public func isEmpty(_ isEmpty: Bool, isHome: Bool, handle: (() -> Void)?) {
//        if isEmpty {
//            let frame = CGRect(x: 0,
//                               y: 0,
//                               width: frame.size.width,
//                               height: frame.size.height)
//            let emptyView = EmptyView(frame: frame)
//            emptyView.configUI(isHome: isHome)
//            emptyView.handleOpen = handle
//            backgroundView = emptyView
//        } else {
//            backgroundView = nil
//        }
//    }
}

// MARK: - Methods
extension UICollectionView {
    
    public func dequeueReusableCell<T: UICollectionViewCell>(withClass name: T.Type, for indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(withReuseIdentifier: String(describing: name), for: indexPath) as? T else {
            fatalError("Couldn't find UICollectionViewCell for \(String(describing: name)), make sure the cell is registered with collection view")
        }
        return cell
    }
    
    public func dequeueReusableSupplementaryView<T: UICollectionReusableView>(ofKind kind: String, withClass name: T.Type, for indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: String(describing: name), for: indexPath) as? T else {
            fatalError("Couldn't find UICollectionReusableView for \(String(describing: name)), make sure the view is registered with collection view")
        }
        return cell
    }
    
    public func register<T: UICollectionReusableView>(withClass name: T.Type,
                                               forSupplementaryViewOfKind kind: String) {
        let identifier = String(describing: name)
        register(UINib(nibName: identifier, bundle: nil),
                 forSupplementaryViewOfKind: kind,
                 withReuseIdentifier: String(describing: name))
    }

    public func register<T: UICollectionViewCell>(nibWithCellClass name: T.Type,
                                                  at bundleClass: AnyClass? = nil) {
        let identifier = String(describing: name)
        var bundle: Bundle?

        if let bundleName = bundleClass {
            bundle = Bundle(for: bundleName)
        }

        register(UINib(nibName: identifier, bundle: bundle), forCellWithReuseIdentifier: identifier)
    }
    
    public func safeScrollToItem(at indexPath: IndexPath, at scrollPosition: UICollectionView.ScrollPosition, animated: Bool) {
        guard indexPath.item >= 0 &&
            indexPath.section >= 0 &&
            indexPath.section < numberOfSections &&
            indexPath.item < numberOfItems(inSection: indexPath.section) else {
                return
        }
        scrollToItem(at: indexPath, at: scrollPosition, animated: animated)
    }
    
    /// Hàm hỗ trợ đăng kí UICollectionReusableView với collection
    public func register<T: UICollectionReusableView>(reusableViewType: T.Type,
                                               ofKind kind: String = UICollectionView.elementKindSectionHeader,
                                               bundle: Bundle? = nil) {
        let className = reusableViewType.className
        let nib = UINib(nibName: className, bundle: bundle)
        register(nib, forSupplementaryViewOfKind: kind, withReuseIdentifier: className)
    }
    
    /// Hàm hỗ trợ sử dụng lại UICollectionReusableView
    public func dequeueReusableView<T: UICollectionReusableView>(with type: T.Type,
                                                          for indexPath: IndexPath,
                                                          ofKind kind: String = UICollectionView.elementKindSectionHeader) -> T {
        return dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: type.className, for: indexPath) as! T
    }
}
