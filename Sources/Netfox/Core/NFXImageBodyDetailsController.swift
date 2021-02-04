//
// plg
// Copyright © 2021 Heads and Hands. All rights reserved.
//

#if os(iOS)

    import Foundation
    import UIKit

    class NFXImageBodyDetailsController: NFXGenericBodyDetailsController {
        // MARK: Lifecycle

        override func viewDidLoad() {
            super.viewDidLoad()

            title = "Image preview"

            imageView.frame = CGRect(x: 10, y: 10, width: view.frame.width - 2 * 10, height: view.frame.height - 2 * 10)
            imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            imageView.contentMode = .scaleAspectFit
            let data = Data(
                base64Encoded: selectedModel.getResponseBody() as String,
                options: NSData.Base64DecodingOptions.ignoreUnknownCharacters
            )

            imageView.image = UIImage(data: data!)

            view.addSubview(imageView)
        }

        // MARK: Internal

        var imageView = UIImageView()
    }

#endif
