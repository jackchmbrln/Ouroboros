//
//  CollectionViewController.swift
//  Ouroboros
//
//  Created by Jack Chamberlain on 03/06/2017.
//  Copyright © 2017 Jack Chamberlain. All rights reserved.
//

import UIKit
import Ouroboros

class CollectionViewController: UIViewController {
  
  @IBOutlet weak var collectionView: OUCollectionView!
  
  var data = Array<String>()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    let nib = UINib(nibName: "CollectionViewCell", bundle: Bundle.main)
    collectionView.register(nib, forCellWithReuseIdentifier: "CollectionViewCell")
    collectionView.infinityDelegate = self
    self.title = "Infinite Collection View"
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
}

extension CollectionViewController: OUInfinityCollectionDelegate {
  func collectionView(_ collectionView: OUCollectionView, willFetchDataAtPage: Int, completion: @escaping OUCompletionBlock) {
    NSLog("Fetch data")
    let firstTodoEndpoint: String = "https://jsonplaceholder.typicode.com/photos"
    var firstTodoUrlRequest = URLRequest(url: URL(string: firstTodoEndpoint)!)
    firstTodoUrlRequest.httpMethod = "GET"
    
    let session = URLSession.shared
    
    let task = session.dataTask(with: firstTodoUrlRequest) {
      (data, response, error) in
      guard let _ = data else {
        return
      }
      DispatchQueue.main.sync {
        for _ in 1...12 {
          self.data.append(String(self.data.count + 1))
        }
        if self.data.count >= 50 {
          self.collectionView.infiniteLoading = false
        }
        completion(true, [self.data.count])
      }
    }
    task.resume()
  }
  
  func collectionView(_ collectionView: OUCollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath) as! CollectionViewCell
    cell.backgroundColor = UIColor.random
    return cell
  }
  
  func collectionViewDidReload(_ collectionView: OUCollectionView) {
    
  }
  
  func collectionView(_ collectionView: OUCollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: (collectionView.bounds.width / 2) - 18, height: 170)
  }
  
  func collectionView(_ collectionView: OUCollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
    return UIEdgeInsetsMake(0.0, 12.0, 0, 12.0)
  }
  
  func collectionView(_ collectionView: OUCollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
    return 6
    
  }
  
  func collectionView(_ collectionView: OUCollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    return 12.0
  }
}

extension UIColor {
  static var random: UIColor {
    let randomRed = CGFloat(drand48())
    let randomGreen = CGFloat(drand48())
    let randomBlue = CGFloat(drand48())
    return UIColor(red: randomRed, green: randomGreen, blue: randomBlue, alpha: 1.0)
  }
}
