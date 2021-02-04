//
// plg
// Copyright © 2021 Heads and Hands. All rights reserved.
//

#if os(iOS)

    import Foundation
    import UIKit

    class NFXRawBodyDetailsController: NFXGenericBodyDetailsController {
        // MARK: Lifecycle

        override func viewDidLoad() {
            super.viewDidLoad()

            title = "Body details"

            bodyView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
            bodyView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            bodyView.backgroundColor = UIColor.clear
            bodyView.textColor = UIColor.NFXGray44Color()
            bodyView.textAlignment = .left
            bodyView.isEditable = false
            bodyView.isSelectable = false
            bodyView.font = UIFont.NFXFont(size: 13)

            let lpgr = UILongPressGestureRecognizer(target: self, action: #selector(NFXRawBodyDetailsController.copyLabel))
            bodyView.addGestureRecognizer(lpgr)

            switch bodyType {
            case .request:
                bodyView.text = selectedModel.getRequestBody() as String
            default:
                bodyView.text = selectedModel.getResponseBody() as String
            }

            view.addSubview(bodyView)
        }

        // MARK: Internal

        var bodyView = UITextView()

        // MARK: Fileprivate

        @objc fileprivate func copyLabel(lpgr: UILongPressGestureRecognizer) {
            guard let text = (lpgr.view as? UITextView)?.text,
                  copyAlert == nil else { return }

            UIPasteboard.general.string = text

            let alert = UIAlertController(title: "Text Copied!", message: nil, preferredStyle: .alert)
            copyAlert = alert

            present(alert, animated: true) { [weak self] in
                guard let self = self else { return }

                Timer.scheduledTimer(
                    timeInterval: 0.45,
                    target: self,
                    selector: #selector(NFXRawBodyDetailsController.dismissCopyAlert),
                    userInfo: nil,
                    repeats: false
                )
            }
        }

        @objc fileprivate func dismissCopyAlert() {
            copyAlert?.dismiss(animated: true) { [weak self] in self?.copyAlert = nil }
        }

        // MARK: Private

        private var copyAlert: UIAlertController?
    }

#endif
