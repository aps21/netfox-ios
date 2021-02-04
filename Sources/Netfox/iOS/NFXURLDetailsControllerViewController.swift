//
// plg
// Copyright © 2021 Heads and Hands. All rights reserved.
//

#if os(iOS)

    import Foundation
    import UIKit

    class NFXURLDetailsController: NFXDetailsController {
        override func viewDidLoad() {
            super.viewDidLoad()
            title = "URL Query Strings"
            view.layer.masksToBounds = true
            view.translatesAutoresizingMaskIntoConstraints = true

            let tableView = UITableView()
            tableView.frame = view.bounds
            tableView.dataSource = self
            tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            view.addSubview(tableView)
        }
    }

    extension NFXURLDetailsController: UITableViewDataSource {
        func numberOfSections(in _: UITableView) -> Int {
            1
        }

        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            var cell: UITableViewCell!
            cell = tableView.dequeueReusableCell(withIdentifier: "cell")
            if cell == nil {
                cell = UITableViewCell(style: .value1, reuseIdentifier: "cell")
            }
            if let queryItem = selectedModel.requestURLQueryItems?[indexPath.row] {
                cell.textLabel?.text = queryItem.name
                cell.detailTextLabel?.text = queryItem.value
            }
            return cell
        }

        func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
            guard let queryItems = selectedModel.requestURLQueryItems else {
                return 0
            }
            return queryItems.count
        }
    }

#endif
