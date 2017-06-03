//
//  ViewController.swift
//  Ouroboros
//
//  Created by Jack Chamberlain on 06/10/2016.
//  Copyright © 2016 Jack Chamberlain. All rights reserved.
//

import UIKit
import Ouroboros

class ViewController: UIViewController {
  
  @IBOutlet weak var tableView: OUTableView!
  
  var data = Array<String>()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    let nib = UINib(nibName: "OUTableViewCell", bundle: Bundle.main)
    tableView.register(nib, forCellReuseIdentifier: "OUTableViewCell")
    tableView.infinityDelegate = self
    
    self.title = "Infinite Table View"
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
}

extension ViewController: OUInfinityTableDelegate, UITableViewDelegate {
  
  func tableView(_ tableView: OUTableView, willFetchDataAt page: Int, completion: @escaping (Bool, [Int]) -> Void) {
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
          completion(false, [self.data.count])
        }
        completion(true, [self.data.count])
      }
    }
    task.resume()
  }
  
  func tableView(_ tableView: OUTableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "OUTableViewCell") as! OUTableViewCell
    if indexPath.row < data.count {
      cell.textLabel?.text = data[indexPath.row]
    }
    return cell
  }
  
  func tableView(_ tableView: OUTableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 75.0
  }
  
  func tableViewDidReload(_ tableView: OUTableView) {
    data = Array<String>()
  }
}

