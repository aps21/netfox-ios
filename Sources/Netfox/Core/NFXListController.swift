//
// plg
// Copyright © 2021 Heads and Hands. All rights reserved.
//

import Foundation

class NFXListController: NFXGenericController {
    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: Internal

    var tableData = [NFXHTTPModel]()
    var filteredTableData = [NFXHTTPModel]()

    func updateSearchResultsForSearchControllerWithString(_ searchString: String) {
        let predicateURL = NSPredicate(format: "requestURL contains[cd] '\(searchString)'")
        let predicateMethod = NSPredicate(format: "requestMethod contains[cd] '\(searchString)'")
        let predicateType = NSPredicate(format: "responseType contains[cd] '\(searchString)'")
        let predicates = [predicateURL, predicateMethod, predicateType]
        let searchPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: predicates)

        let array = (NFXHTTPModelManager.sharedInstance.getModels() as NSArray).filtered(using: searchPredicate)
        filteredTableData = array as! [NFXHTTPModel]
    }

    @objc func reloadTableViewData() {}
}
