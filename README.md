![alt tag][image-1]
# Ouroboros 🐍
A super simple framework for creating infinitely loading table and collection views in Swift

Ouroboros extends off of `UITableView` and `UICollectionView` to make creating infinitely scrolling lists as effortless as possible. Instead of using the default UIKit classes uses `OUTableView` and `OUCollectionView`

## OUTableView

When creating a table view instead of using `UITableViewDataSource` and `UITableViewDelegate`make your class adhere to the `OUInfinityTableDelegate` protocol.

This protocol has 3 main functions:

	func tableView(_ tableView: OUTableView, willFetchDataAt page: Int, completion: @escaping OUCompletionBlock)

This is called when the tableview is ready to fetch more data. The page number is managed by the table view. The completion block contains two parameters:
- `infiniteLoading`- this is a Bool that tells the table view whether to continue fetching new data
- `dataCount` - this is an array that manages the number of sections/rows. It is defined as `Array<Int>` with the count being the number of sections and the `Int` at `dataCount[section]` being the number of rows in that section.  

	 func tableView(_ tableView: OUTableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell

This is the same as the default `cellForRowAtIndexPath` - return the cell that you want to use  
 
	 func tableViewDidReload(_ tableView: OUTableView)  

This is called everytime the table view is refreshed via the `UIRefreshControl`.

After this the majority of the functions associated with `UITableViewDelegate` and `UITableViewDataSource` are implemented as part of `OUInfinityTableDelegate `

## OUCollectionView

The same three functions exist for `OUCollectionView` as part of `OUInfinityCollectionDelegate`:

	func collectionView(_ collectionView: OUCollectionView, willFetchDataAt page: Int, completion: @escaping OUCompletionBlock)

	 func collectionView(_ collectionView: OUCollectionView, cellForRowAt indexPath: IndexPath) -> UICollectionViewCell

	 func collectionView DidReload(_ collectionView: OUCollectionView)

### Loading cell

A default loading cell is provided by Ouroboros but you can override this by doing 

	myInfiniteTableView.loadingCellIdentifier = "CustomLoadingCell"

When setting this you have to ensure that the nib name and reuse identifier are the same or it will cause an exception.

### Example

See the Demo Project for a fully working example of `OUTableView` and `OUCollectionView`

	extension ViewController: OUInfinityTableDelegate {
	  
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


[image-1]:	https://raw.githubusercontent.com/jackchmbrln/Ouroboros/master/ouro_logo@2x.png