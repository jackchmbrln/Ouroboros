//
//  OUCollectionView.swift
//  Ouroboros
//
//  Created by Jack Chamberlain on 02/06/2017.
//  Copyright © 2017 Jack Chamberlain. All rights reserved.
//

import UIKit

@objc public protocol OUInfinityCollectionDelegate {
  
  // MARK: Required infinity delegates
  
  func collectionView(_ collectionView: OUCollectionView, willFetchDataAtPage: Int, completion: @escaping OUCompletionBlock)
  func collectionView(_ collectionView: OUCollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
  func collectionViewDidReload(_ collectionView: OUCollectionView)
  
  @objc optional func collectionView(_ collectionView: OUCollectionView, didSelectItemAt indexPath: IndexPath)
  @objc optional func collectionView(_ collectionView: OUCollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
  @objc optional func collectionView(_ collectionView: OUCollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets
  @objc optional func collectionView(_ collectionView: OUCollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat
  @objc optional func collectionView(_ collectionView: OUCollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat
}

public class OUCollectionView: UICollectionView {
  
  // MARK: Definitions
  
  // Infinity delegate
  // Controls the sourcing and setting of data throughout the table view
  
  public var infinityDelegate: OUInfinityCollectionDelegate?
  
  // Data
  // An array of data used by the table view
  
  public var dataCount = [0]
  
  // Buffer count
  // Defines the number of buffer cells to the bottom of a table view
  // until willFetchDataAtPage is called
  // Default is 3
  
  public var buffer: Int = 5
  
  // MARK: Required constants
  
  // MARK: Page number
  
  fileprivate var page: Int = 1
  
  fileprivate var isLoadingData = false
  
  // MARK: Infinite loading
  // By default is set to true so that the infinity delegate will be called whenever the user reaches the bottom of the page
  // Can be set to true to disable this behaviour
  
  public var infiniteLoading: Bool = true
  
  public var loadingCellIdentifier: String = "OUCollectionLoadingCell" {
    didSet {
      setup()
    }
  }
  
  public override func awakeFromNib() {
    super.awakeFromNib()
    self.setup()
  }
  
  // MARK: Setup
  
  private func setup() -> Void {
    dataCount = [0]
    
    self.dataSource = self
    self.delegate = self
    
    // MARK: Register default loading cell
    let bundle = Bundle(identifier: "uk.jackchmbrln.Ouroboros")
    
    let loadingCellNib = UINib(nibName: loadingCellIdentifier, bundle: bundle)
    register(loadingCellNib, forCellWithReuseIdentifier: loadingCellIdentifier)
    
    refreshControl = UIRefreshControl()
    refreshControl?.addTarget(self, action: #selector(reload), for: .valueChanged)
    addSubview(refreshControl!)
  }
  
  public func reload() {
    dataCount = [0]
    page = 1
    infiniteLoading = true
    infinityDelegate?.collectionViewDidReload(self)
    infinityDelegate?.collectionView(self, willFetchDataAtPage: self.page, completion: { (infiniteLoading, data) in
      self.handleResponse(infiniteLoading: infiniteLoading, count: data)
      self.refreshControl?.endRefreshing()
      return
    })
  }
}

extension OUCollectionView: UICollectionViewDataSource, UICollectionViewDelegate {
  
  public func numberOfSections(in collectionView: UICollectionView) -> Int {
    if infiniteLoading {
      return dataCount.count + 1
    }
    
    return dataCount.count
  }
  
  public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    if infiniteLoading && section == dataCount.count {
      return 1
    }
    return dataCount[section]
  }
  
  public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard let delegate = self.infinityDelegate else {
      return UICollectionViewCell()
    }
    
    if infiniteLoading {
      if indexPath.section == dataCount.count {
        let cell = dequeueReusableCell(withReuseIdentifier: loadingCellIdentifier, for: indexPath)
        return cell
      }
    }
    
    return delegate.collectionView(self, cellForItemAt: indexPath)
  }
  
  // MARK: Handle infinity delegate response
  
  fileprivate func handleResponse(infiniteLoading: Bool, count: [Int]?) {
    self.infiniteLoading = infiniteLoading
    if let newData = count {
      if self.page == 1 {
        dataCount.removeAll()
      }
      
      dataCount = newData
      
      page += 1
      reloadData()
      isLoadingData = false
    }
  }
  
  public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    infinityDelegate?.collectionView?(self, didSelectItemAt: indexPath)
  }
  
  public func scrollViewDidScroll(_ scrollView: UIScrollView) {
    if isLoadingData { return }
    if !infiniteLoading { return }
    
    let height = scrollView.frame.size.height
    let contentYOffset = scrollView.contentOffset.y
    let distance = scrollView.contentSize.height - contentYOffset
    
    if distance < height + 500 {
      isLoadingData = true
      infinityDelegate?.collectionView(self, willFetchDataAtPage: self.page, completion: { (infiniteLoading, data) in
        self.handleResponse(infiniteLoading: infiniteLoading, count: data)
        return
      })
    }
  }
  
}

extension OUCollectionView: UICollectionViewDelegateFlowLayout {
  
  public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    if indexPath.section == dataCount.count {
      return CGSize(width: bounds.width, height: 100)
    }
    return infinityDelegate?.collectionView?(self, layout: collectionViewLayout, sizeForItemAt: indexPath) ?? CGSize(width: 100, height: 100)
  }
  
  public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
    let defaultInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    return infinityDelegate?.collectionView?(self, layout: collectionViewLayout, insetForSectionAt: section) ?? defaultInsets
  }
  
  public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
    let defaultSpacing: CGFloat = 0.0
    return infinityDelegate?.collectionView?(self, layout: collectionViewLayout, minimumInteritemSpacingForSectionAt: section) ?? defaultSpacing
  }
  
  public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    let defaultSpacing: CGFloat = 0.0
    return infinityDelegate?.collectionView?(self, layout: collectionViewLayout, minimumLineSpacingForSectionAt: section) ?? defaultSpacing
  }
  
}
