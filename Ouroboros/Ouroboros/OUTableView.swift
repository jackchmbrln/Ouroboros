//
//  OUTableView.swift
//  Ouroboros
//
//  Created by Jack Chamberlain on 06/10/2016.
//  Copyright © 2016 Jack Chamberlain. All rights reserved.
//

import UIKit

public typealias OUCompletionBlock = (_ success: Bool, _ data: [[Int]]) -> Void

@objc public protocol OUInfinityDelegate {
   
   // MARK: Required infinity delegates
   
   func tableView(tableView: OUTableView, willFetchDataAtPage: Int, completion: @escaping OUCompletionBlock)
   func tableView(tableView: OUTableView, cellForRowAt indexPath: IndexPath, loadingCell: Bool) -> UITableViewCell
   func tableViewDidReload(tableView: OUTableView)
   
   // Optional delegate functions
   
   @objc optional func tableView(tableView: OUTableView, heightForRowAt indexPath: IndexPath) -> CGFloat
   @objc optional func tableView(tableView: OUTableView, heightForHeaderInSection section: Int) -> CGFloat
   @objc optional func tableView(tableView: OUTableView, heightForFooterInSection section: Int) -> CGFloat
   @objc optional func tableView(tableView: OUTableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat
   @objc optional func tableView(tableView: OUTableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat
   @objc optional func tableView(tableView: OUTableView, estimatedHeightForFooterInSection section: Int) -> CGFloat
}

public class OUTableView: UITableView {
   
   // MARK: Definitions
   
   // Infinity delegate
   // Controls the sourcing and setting of data throughout the table view
   
   public var infinityDelegate: OUInfinityDelegate?
   
   // Data
   // An array of data used by the table view
   
   public var dataCount = [[1]]
   
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
   
   public override func awakeFromNib() {
      super.awakeFromNib()
      self.setup()
   }
   
   // MARK: Setup
   
   private func setup() -> Void {
      self.dataSource = self
      self.delegate = self
      
      // MARK: Register default loading cell
      
      let loadingCellNib = UINib(nibName: "OULoadingTableViewCell", bundle: Bundle.main)
      self.register(loadingCellNib, forCellReuseIdentifier: "OULoadingTableViewCell")
      
      refreshControl = UIRefreshControl()
      refreshControl?.addTarget(self, action: #selector(reload), for: .valueChanged)
      addSubview(refreshControl!)
   }
   
   public func reload() {
      dataCount = [[1]]
      page = 1
      infiniteLoading = true
      infinityDelegate?.tableViewDidReload(tableView: self)
      infinityDelegate?.tableView(tableView: self, willFetchDataAtPage: self.page, completion: { (success, data) in
         self.handleResponse(with: success, count: data)
         self.refreshControl?.endRefreshing()
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
         return (dataCount[section].first ?? 1) + 1
      }
      return dataCount[section].first ?? 1
   }
   
   // MARK: Cell for row at indexPath
   
   public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      guard let delegate = self.infinityDelegate else {
         return UITableViewCell()
      }
      
      // If it is last index of the last section then we want to return the loading cell
      
      let lastSectionIndex = tableView.numberOfSections - 1
      let lastRowIndex = tableView.numberOfRows(inSection: lastSectionIndex) - 1
      
      if indexPath.row == lastRowIndex {
         if infiniteLoading {
            return delegate.tableView(tableView: self, cellForRowAt: indexPath, loadingCell: true)
         }
      }
      
      return delegate.tableView(tableView: self, cellForRowAt: indexPath, loadingCell: false)
   }
   
   // MARK: Handle infinity delegate response
   
   fileprivate func handleResponse(with success: Bool, count: [[Int]]?) {
      if let newData = count {
         if self.page == 1 {
            dataCount.removeAll()
         }
         
         dataCount = newData
         
         self.page += 1
         self.reloadData()
      }
   }
   
}

extension OUTableView: UITableViewDelegate {
   
   public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
      if infiniteLoading {
         guard let count = self.dataCount.last?.first else { return }
         if indexPath.row >= (count - self.buffer) && !isLoadingData {
            isLoadingData = true
            infinityDelegate?.tableView(tableView: self, willFetchDataAtPage: self.page, completion: { (success, data) in
               self.isLoadingData = false
               self.handleResponse(with: success, count: data)
               return
            })
         }
      }
   }
   
   // MARK: Optional delegates
   
   public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
      return (self.infinityDelegate?.tableView?(tableView: self, heightForRowAt: indexPath)) ?? 45.0
   }
   
   public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
      return (self.infinityDelegate?.tableView?(tableView: self, heightForHeaderInSection: section)) ?? 0.0
   }
   
   public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
      return (self.infinityDelegate?.tableView?(tableView: self, heightForFooterInSection: section)) ?? 0.0
   }
   
   public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
      return (self.infinityDelegate?.tableView?(tableView: self, estimatedHeightForRowAt: indexPath)) ?? UITableViewAutomaticDimension
   }
   
   public func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
      return (self.infinityDelegate?.tableView?(tableView: self, estimatedHeightForFooterInSection: section)) ?? 0.0
   }
   
   public func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
      return (self.infinityDelegate?.tableView?(tableView: self, estimatedHeightForFooterInSection: section)) ?? 0.0
   }
   
}
