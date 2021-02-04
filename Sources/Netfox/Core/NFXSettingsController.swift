//
// plg
// Copyright © 2021 Heads and Hands. All rights reserved.
//

import Foundation

class NFXSettingsController: NFXGenericController {
    // MARK: Properties

    let nfxVersionString = "netfox - \(nfxVersion)"
    var nfxURL = "https://github.com/kasketis/netfox"

    var tableData = [HTTPModelShortType]()
    var filters = [Bool]()
}
