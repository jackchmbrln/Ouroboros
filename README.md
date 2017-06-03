![alt tag][image-1]
# Ouroboros 🐍
A super simple framework for creating infinitely loading table and collection views in Swift

Ouroboros extends off of `UITableView` and `UICollectionView` to make creating infinitely scrolling lists as effortless as possible. Instead of using the default UIKit classes uses `OUTableView` and `OUCollectionView`

## \#OUTableView

When creating a table view instead of using `UITableViewDataSource` and `UITableViewDelegate`make your class adhere to the `OUInfinityTableDelegate` protocol.

This protocol has 3 main functions:

`func tableView(_ tableView: OUTableView, willFetchDataAt page: Int, completion: @escaping OUCompletionBlock)`  

This is called when the tableview is ready to fetch more data. The page number is managed by the table view. The completion block contains two parameters:
- `infiniteLoading`- this is a Bool that tells the table view whether to continue fetching new data
- `dataCount` - this is an array that manages the number of sections/rows. It is defined as `Array<Int>` with the count being the number of sections and the `Int` at `dataCount[section]` being the number of rows in that section.  

 `func tableView(_ tableView: OUTableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell`

This is the same as the default `cellForRowAtIndexPath` - return the cell that you want to use  
 
 `func tableViewDidReload(_ tableView: OUTableView)`  

This is called everytime the table view is refreshed via the `UIRefreshControl`.

After this the majority of the functions associated with `UITableViewDelegate` and `UITableViewDataSource` are implemented as part of `OUInfinityTableDelegate `

### OUCollectionView

The same three functions exist for `OUCollectionView` as part of `OUInfinityCollectionDelegate`:

`func collectionView(_ collectionView: OUCollectionView, willFetchDataAt page: Int, completion: @escaping OUCompletionBlock)`

 `func collectionView(_ collectionView: OUCollectionView, cellForRowAt indexPath: IndexPath) -> UICollectionViewCell`

 `func collectionView DidReload(_ collectionView: OUCollectionView)`

### Loading cell

A default loading cell is provided by Ouroboros but you can override this by doing 

`myInfiniteTableView.loadingCellIdentifier = "CustomLoadingCell"`

When setting this you have to ensure that the nib name and reuse identifier are the same or it will cause an exception.

[image-1]:	https://raw.githubusercontent.com/jackchmbrln/Ouroboros/master/ouro_logo@2x.png