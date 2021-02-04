//
// plg
// Copyright © 2021 Heads and Hands. All rights reserved.
//

import Foundation

// MARK: - NFXBodyType

enum NFXBodyType: Int {
    case request = 0
    case response = 1
}

// MARK: - NFXGenericBodyDetailsController

class NFXGenericBodyDetailsController: NFXGenericController {
    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: Internal

    var bodyType = NFXBodyType.response
}
