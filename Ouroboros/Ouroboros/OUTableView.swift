//
//  OUTableView.swift
//  Ouroboros
//
//  Created by Jack Chamberlain on 06/10/2016.
//  Copyright © 2016 Jack Chamberlain. All rights reserved.
//

import UIKit

public typealias OUCompletionBlock = (_ infiniteLoding: Bool, _ data: [Int]) -> Void

@objc public protocol OUInfinityTableDelegate {
  
  // MARK: Required infinity delegates
  
  func tableView(_ tableView: OUTableView, willFetchDataAt page: Int, completion: @escaping OUCompletionBlock)
  func tableView(_ tableView: OUTableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
  func tableViewDidReload(_ tableView: OUTableView)
  
  // Optional delegate functions
  
  @objc optional func tableView(_ tableView: OUTableView, didSelectRowAt indexPath: IndexPath)
  @objc optional func tableView(_ tableView: OUTableView, heightForRowAt indexPath: IndexPath) -> CGFloat
  @objc optional func tableView(_ tableView: OUTableView, heightForHeaderInSection section: Int) -> CGFloat
  @objc optional func tableView(_ tableView: OUTableView, heightForFooterInSection section: Int) -> CGFloat
  @objc optional func tableView(_ tableView: OUTableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat
  @objc optional func tableView(_ tableView: OUTableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat
  @objc optional func tableView(_ tableView: OUTableView, estimatedHeightForFooterInSection section: Int) -> CGFloat
  @objc optional func tableView(_ tableView: OUTableView, viewForHeaderInSection section: Int) -> UIView?
}

public class OUTableView: UITableView {
  
  // MARK: Definitions
  
  // Infinity delegate
  // Controls the sourcing and setting of data throughout the table view
  
  public var infinityDelegate: OUInfinityTableDelegate? {
    didSet {
      reload()
    }
  }
  
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
  
  public var loadingCellIdentifier: String = "OULoadingTableViewCell" {
    didSet {
      setup()
    }
  }
  
  var reloadControl: UIRefreshControl?
  
  public override func awakeFromNib() {
    super.awakeFromNib()
    self.setup()
  }
  
  // MARK: Setup
  
  private func setup() -> Void {
    dataSource = self
    delegate = self
    
    // MARK: Register default loading cell
    
    let bundle = Bundle(identifier: "uk.jackchmbrln.Ouroboros")
    
    let loadingCellNib = UINib(nibName: loadingCellIdentifier, bundle: bundle)
    register(loadingCellNib, forCellReuseIdentifier: loadingCellIdentifier)
    
    reloadControl = UIRefreshControl()
    reloadControl?.addTarget(self, action: #selector(reload), for: .valueChanged)
    addSubview(reloadControl!)
  }
  
  public func reload() {
    dataCount = [0]
    page = 1
    infiniteLoading = true
    infinityDelegate?.tableViewDidReload(self)
    infinityDelegate?.tableView(self, willFetchDataAt: self.page, completion: { (infiniteLoading, data) in
      self.handleResponse(infiniteLoading: infiniteLoading, count: data)
      self.reloadControl?.endRefreshing()
      return
    })
  }
}

extension OUTableView: UITableViewDataSource {
  
  // MARK: Number of sections in tableView
  
  public func numberOfSections(in tableView: UITableView) -> Int {
    return dataCount.count
  }
  
  // MARK: Number of rows in section
  
  public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if infiniteLoading {
      if section == dataCount.count - 1 {
        return dataCount[section] + 1
      }
    }
    
    return dataCount[section]
  }
  
  // MARK: Cell for row at indexPath
  
  public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let delegate = self.infinityDelegate else {
      return UITableViewCell()
    }
    
    if infiniteLoading {
      if indexPath.section == dataCount.count - 1 {
        if indexPath.row ==  dataCount[dataCount.count - 1] {
          let cell = dequeueReusableCell(withIdentifier: loadingCellIdentifier)!
          return cell
        }
      }
    }
    
    return delegate.tableView(self, cellForRowAt: indexPath)
  }
  
  // MARK: Handle infinity delegate response
  
  fileprivate func handleResponse(infiniteLoading: Bool, count: [Int]?) {
    self.infiniteLoading = infiniteLoading
    if let newData = count {
      if self.page == 1 {
        dataCount.removeAll()
      }
      
      dataCount = newData
      
      self.page += 1
      self.reloadData()
      self.isLoadingData = false
    }
  }
  
}

extension OUTableView: UITableViewDelegate {
  
  public func scrollViewDidScroll(_ scrollView: UIScrollView) {
    if isLoadingData { return }
    if !infiniteLoading { return }
    
    let height = scrollView.frame.size.height
    let contentYOffset = scrollView.contentOffset.y
    let distance = scrollView.contentSize.height - contentYOffset
    
    if distance < height + 500 {
      isLoadingData = true
      infinityDelegate?.tableView(self, willFetchDataAt: self.page, completion: { (infiniteLoading, data) in
        self.handleResponse(infiniteLoading: infiniteLoading, count: data)
        return
      })
    }
  }
  
  // MARK: Optional delegates
  
  public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return (self.infinityDelegate?.tableView?(self, heightForRowAt: indexPath)) ?? 45.0
  }
  
  public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    return infinityDelegate?.tableView?(self, viewForHeaderInSection: section)
  }
  
  public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    return (self.infinityDelegate?.tableView?(self, heightForFooterInSection: section)) ?? 0.0
  }
  
  public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
    return (self.infinityDelegate?.tableView?(self, estimatedHeightForRowAt: indexPath)) ?? UITableViewAutomaticDimension
  }
  
  public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    infinityDelegate?.tableView?(self, didSelectRowAt: indexPath)
  }
}
