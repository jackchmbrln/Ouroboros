![alt tag](https://raw.githubusercontent.com/jackchmbrln/Ouroboros/master/ouro_logo%402x.png)
# Ouroboros 🐍
A super simple framework for creating infinitely loading table and collection views in Swift

Ouroboros extends off of `UITableView` and `UICollectionView` to make creating infinitely scrolling lists as effortless as possible. Instead of using the default UIKit classes uses `OUTableView` and `OUCollectionView`

##OUTableView

When creating a table view instead of using `UITableViewDataSource` and `UITableViewDelegate`make your class adhere to the `OUInfinityTableDelegate` protocol.

This protocol has 3 main functions:

`func tableView(_ tableView: OUTableView, willFetchDataAt page: Int, completion: @escaping OUCompletionBlock)  

 func tableView(_ tableView: OUTableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell  
 
 func tableViewDidReload(_ tableView: OUTableView)`  
