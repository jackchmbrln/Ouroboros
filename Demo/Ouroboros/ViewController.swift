//
//  ViewController.swift
//  Ouroboros
//
//  Created by Jack Chamberlain on 06/10/2016.
//  Copyright © 2016 Jack Chamberlain. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
   
   @IBOutlet weak var tableView: OUTableView!
   
   var data = Array<String>()
   
   override func viewDidLoad() {
      super.viewDidLoad()
      // Do any additional setup after loading the view, typically from a nib.
      let nib = UINib(nibName: "OUTableViewCell", bundle: Bundle.main)
      tableView.register(nib, forCellReuseIdentifier: "OUTableViewCell")
      let loadingCellNib = UINib(nibName: "OULoadingTableViewCell", bundle: Bundle.main)
      tableView.register(loadingCellNib, forCellReuseIdentifier: "OULoadingTableViewCell")
      tableView.infinityDelegate = self
   }
   
   override func didReceiveMemoryWarning() {
      super.didReceiveMemoryWarning()
      // Dispose of any resources that can be recreated.
   }
}

extension ViewController: OUInfinityDelegate, UITableViewDelegate {
   
   func tableView(tableView: OUTableView, willFetchDataAtPage: Int, completion: @escaping (Bool, [[Int]]) -> Void) {
      NSLog("Fetch data")
      let firstTodoEndpoint: String = "https://jsonplaceholder.typicode.com/photos"
      var firstTodoUrlRequest = URLRequest(url: URL(string: firstTodoEndpoint)!)
      firstTodoUrlRequest.httpMethod = "GET"
      
      let session = URLSession.shared
      
      let task = session.dataTask(with: firstTodoUrlRequest) {
         (data, response, error) in
         guard let _ = data else {
            print("error calling DELETE on /todos/1")
            return
         }
         DispatchQueue.main.sync {
            for _ in 1...8 {
               self.data.append(String(self.data.count + 1))
            }
            if self.data.count >= 50 {
               self.tableView.infiniteLoading = false
            }
            completion(true, [[self.data.count]])
         }
      }
      task.resume()
   }
   
   func tableView(tableView: OUTableView, cellForRowAt indexPath: IndexPath, loadingCell: Bool) -> UITableViewCell {
      if !loadingCell {
         let cell = tableView.dequeueReusableCell(withIdentifier: "OUTableViewCell") as! OUTableViewCell
         if indexPath.row < data.count {
            cell.textLabel?.text = data[indexPath.row]
         }
         return cell
      } else {
         let cell = tableView.dequeueReusableCell(withIdentifier: "OULoadingTableViewCell") as! OULoadingTableViewCell
         return cell
      }
   }
   
   func tableView(tableView: OUTableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
      return 75.0
   }
   
   func tableViewDidReload(tableView: OUTableView) {
      data = Array<String>()
   }
}

