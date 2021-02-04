//
// plg
// Copyright © 2021 Heads and Hands. All rights reserved.
//

#if os(iOS)

    import Foundation
    import MessageUI
    import UIKit
    fileprivate func < <T: Comparable>(lhs: T?, rhs: T?) -> Bool {
        switch (lhs, rhs) {
        case let (l?, r?):
            return l < r
        case (nil, _?):
            return true
        default:
            return false
        }
    }

    fileprivate func > <T: Comparable>(lhs: T?, rhs: T?) -> Bool {
        switch (lhs, rhs) {
        case let (l?, r?):
            return l > r
        default:
            return rhs < lhs
        }
    }

    class NFXDetailsController_iOS: NFXDetailsController, MFMailComposeViewControllerDelegate {
        // MARK: Lifecycle

        override func viewDidLoad() {
            super.viewDidLoad()

            title = "Details"
            view.layer.masksToBounds = true

            navigationItem.rightBarButtonItem = UIBarButtonItem(
                barButtonSystemItem: .action,
                target: self,
                action: #selector(NFXDetailsController_iOS.actionButtonPressed(_:))
            )

            // Header buttons
            infoButton = createHeaderButton("Info", x: 0, selector: #selector(NFXDetailsController_iOS.infoButtonPressed))
            requestButton = createHeaderButton(
                "Request",
                x: infoButton.frame.maxX,
                selector: #selector(NFXDetailsController_iOS.requestButtonPressed)
            )
            responseButton = createHeaderButton(
                "Response",
                x: requestButton.frame.maxX,
                selector: #selector(NFXDetailsController_iOS.responseButtonPressed)
            )
            headerButtons.forEach { self.view.addSubview($0) }

            // Info views
            infoView = createDetailsView(getInfoStringFromObject(selectedModel), forView: .info)
            requestView = createDetailsView(getRequestStringFromObject(selectedModel), forView: .request)
            responseView = createDetailsView(getResponseStringFromObject(selectedModel), forView: .response)
            infoViews.forEach { self.view.addSubview($0) }

            // Swipe gestures
            let lswgr = UISwipeGestureRecognizer(target: self, action: #selector(NFXDetailsController_iOS.handleSwipe(_:)))
            lswgr.direction = .left
            view.addGestureRecognizer(lswgr)

            let rswgr = UISwipeGestureRecognizer(target: self, action: #selector(NFXDetailsController_iOS.handleSwipe(_:)))
            rswgr.direction = .right
            view.addGestureRecognizer(rswgr)

            infoButtonPressed()
        }

        // MARK: Internal

        var infoButton = UIButton()
        var requestButton = UIButton()
        var responseButton = UIButton()

        var infoView = UIScrollView()
        var requestView = UIScrollView()
        var responseView = UIScrollView()

        internal var sharedContent: String?

        func createHeaderButton(_ title: String, x: CGFloat, selector: Selector) -> UIButton {
            var tempButton: UIButton
            tempButton = UIButton()
            tempButton.frame = CGRect(x: x, y: 0, width: view.frame.width / 3, height: 44)
            tempButton.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin, .flexibleWidth]
            tempButton.backgroundColor = UIColor.NFXDarkStarkWhiteColor()
            tempButton.setTitle(title, for: .init())
            tempButton.setTitleColor(UIColor(netHex: 0x6D6D6D), for: .init())
            tempButton.setTitleColor(UIColor(netHex: 0xF3F3F4), for: .selected)
            tempButton.titleLabel?.font = UIFont.NFXFont(size: 15)
            tempButton.addTarget(self, action: selector, for: .touchUpInside)
            return tempButton
        }

        func createDetailsView(_ content: NSAttributedString, forView: EDetailsView) -> UIScrollView {
            var scrollView: UIScrollView
            scrollView = UIScrollView()
            scrollView.frame = CGRect(x: 0, y: 44, width: view.frame.width, height: view.frame.height - 44)
            scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            scrollView.autoresizesSubviews = true
            scrollView.backgroundColor = UIColor.clear

            var textView: UITextView
            textView = UITextView()
            textView.frame = CGRect(x: 20, y: 20, width: scrollView.frame.width - 40, height: scrollView.frame.height - 20)
            textView.backgroundColor = UIColor.clear
            textView.font = UIFont.NFXFont(size: 13)
            textView.textColor = UIColor.NFXGray44Color()
            textView.isEditable = false
            textView.attributedText = content
            textView.sizeToFit()
            textView.isUserInteractionEnabled = true
            textView.delegate = self
            scrollView.addSubview(textView)

            let lpgr = UILongPressGestureRecognizer(target: self, action: #selector(NFXDetailsController_iOS.copyLabel))
            textView.addGestureRecognizer(lpgr)

            var moreButton: UIButton
            moreButton = UIButton(frame: CGRect(x: 20, y: textView.frame.maxY + 10, width: scrollView.frame.width - 40, height: 40))
            moreButton.backgroundColor = UIColor.NFXGray44Color()

            if forView == EDetailsView.request, selectedModel.requestBodyLength > 1024 {
                moreButton.setTitle("Show request body", for: .init())
                moreButton.addTarget(self, action: #selector(NFXDetailsController_iOS.requestBodyButtonPressed), for: .touchUpInside)
                scrollView.addSubview(moreButton)
                scrollView.contentSize = CGSize(width: textView.frame.width, height: moreButton.frame.maxY + 16)

            } else if forView == EDetailsView.response, selectedModel.responseBodyLength > 1024 {
                moreButton.setTitle("Show response body", for: .init())
                moreButton.addTarget(self, action: #selector(NFXDetailsController_iOS.responseBodyButtonPressed), for: .touchUpInside)
                scrollView.addSubview(moreButton)
                scrollView.contentSize = CGSize(width: textView.frame.width, height: moreButton.frame.maxY + 16)

            } else {
                scrollView.contentSize = CGSize(width: textView.frame.width, height: textView.frame.maxY + 16)
            }

            return scrollView
        }

        @objc func actionButtonPressed(_ sender: UIBarButtonItem) {
            let actionSheetController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
            actionSheetController.addAction(cancelAction)

            let simpleLog = UIAlertAction(title: "Simple log", style: .default) { [unowned self] _ -> Void in
                self.shareLog(full: false, sender: sender)
            }
            actionSheetController.addAction(simpleLog)

            let fullLogAction = UIAlertAction(title: "Full log", style: .default) { [unowned self] _ -> Void in
                self.shareLog(full: true, sender: sender)
            }
            actionSheetController.addAction(fullLogAction)

            if let reqCurl = selectedModel.requestCurl {
                let curlAction = UIAlertAction(title: "Export request as curl", style: .default) { [unowned self] _ -> Void in
                    let activityViewController = UIActivityViewController(activityItems: [reqCurl], applicationActivities: nil)
                    activityViewController.popoverPresentationController?.barButtonItem = sender
                    self.present(activityViewController, animated: true, completion: nil)
                }
                actionSheetController.addAction(curlAction)
            }

            actionSheetController.view.tintColor = UIColor.NFXOrangeColor()
            actionSheetController.popoverPresentationController?.barButtonItem = sender

            present(actionSheetController, animated: true, completion: nil)
        }

        @objc func infoButtonPressed() {
            buttonPressed(infoButton)
        }

        @objc func requestButtonPressed() {
            buttonPressed(requestButton)
        }

        @objc func responseButtonPressed() {
            buttonPressed(responseButton)
        }

        @objc func handleSwipe(_ gesture: UISwipeGestureRecognizer) {
            guard let currentButtonIdx = headerButtons.firstIndex(where: { $0.isSelected }) else { return }
            let numButtons = headerButtons.count

            switch gesture.direction {
            case .left:
                let nextIdx = currentButtonIdx + 1
                buttonPressed(headerButtons[nextIdx > numButtons - 1 ? 0 : nextIdx])
            case .right:
                let previousIdx = currentButtonIdx - 1
                buttonPressed(headerButtons[previousIdx < 0 ? numButtons - 1 : previousIdx])
            default: break
            }
        }

        func buttonPressed(_ sender: UIButton) {
            guard let selectedButtonIdx = headerButtons.firstIndex(of: sender) else { return }
            let infoViews = [infoView, requestView, responseView]

            UIView.animate(
                withDuration: 0.4,
                delay: 0.0,
                usingSpringWithDamping: 0.8,
                initialSpringVelocity: 0.7,
                options: .curveEaseInOut,
                animations: { [unowned self] in
                    self.headerButtons.indices.forEach {
                        let button = self.headerButtons[$0]
                        let view = infoViews[$0]

                        button.isSelected = button == sender
                        view.frame = CGRect(
                            x: CGFloat(-selectedButtonIdx + $0) * view.frame.size.width,
                            y: view.frame.origin.y,
                            width: view.frame.size.width,
                            height: view.frame.size.height
                        )
                    }
                },
                completion: nil
            )
        }

        @objc func responseBodyButtonPressed() {
            bodyButtonPressed().bodyType = NFXBodyType.response
        }

        @objc func requestBodyButtonPressed() {
            bodyButtonPressed().bodyType = NFXBodyType.request
        }

        func bodyButtonPressed() -> NFXGenericBodyDetailsController {
            var bodyDetailsController: NFXGenericBodyDetailsController

            if selectedModel.shortType as String == HTTPModelShortType.IMAGE.rawValue {
                bodyDetailsController = NFXImageBodyDetailsController()
            } else {
                bodyDetailsController = NFXRawBodyDetailsController()
            }
            bodyDetailsController.selectedModel(selectedModel)
            navigationController?.pushViewController(bodyDetailsController, animated: true)
            return bodyDetailsController
        }

        func shareLog(full: Bool, sender: UIBarButtonItem) {
            var tempString = String()

            tempString += "** INFO **\n"
            tempString += "\(getInfoStringFromObject(selectedModel).string)\n\n"

            tempString += "** REQUEST **\n"
            tempString += "\(getRequestStringFromObject(selectedModel).string)\n\n"

            tempString += "** RESPONSE **\n"
            tempString += "\(getResponseStringFromObject(selectedModel).string)\n\n"

            tempString += "logged via netfox - [https://github.com/kasketis/netfox]\n"

            if full {
                let requestFilePath = selectedModel.getRequestBodyFilepath()
                if let requestFileData = try? String(contentsOf: URL(fileURLWithPath: requestFilePath as String), encoding: .utf8) {
                    tempString += requestFileData
                }

                let responseFilePath = selectedModel.getResponseBodyFilepath()
                if let responseFileData = try? String(contentsOf: URL(fileURLWithPath: responseFilePath as String), encoding: .utf8) {
                    tempString += responseFileData
                }
            }
            displayShareSheet(shareContent: tempString, sender: sender)
        }

        func displayShareSheet(shareContent: String, sender: UIBarButtonItem) {
            sharedContent = shareContent
            let activityViewController = UIActivityViewController(activityItems: [self], applicationActivities: nil)
            activityViewController.popoverPresentationController?.barButtonItem = sender
            present(activityViewController, animated: true, completion: nil)
        }

        // MARK: Fileprivate

        @objc fileprivate func copyLabel(lpgr: UILongPressGestureRecognizer) {
            guard let text = (lpgr.view as? UILabel)?.text,
                  copyAlert == nil else { return }

            UIPasteboard.general.string = text

            let alert = UIAlertController(title: "Text Copied!", message: nil, preferredStyle: .alert)
            copyAlert = alert

            present(alert, animated: true) { [weak self] in
                guard let self = self else { return }

                Timer.scheduledTimer(
                    timeInterval: 0.45,
                    target: self,
                    selector: #selector(NFXDetailsController_iOS.dismissCopyAlert),
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

        private lazy var headerButtons: [UIButton] = {
            [self.infoButton, self.requestButton, self.responseButton]
        }()

        private lazy var infoViews: [UIScrollView] = {
            [self.infoView, self.requestView, self.responseView]
        }()
    }

    extension NFXDetailsController_iOS: UIActivityItemSource {
        public typealias UIActivityType = UIActivity.ActivityType

        func activityViewControllerPlaceholderItem(_: UIActivityViewController) -> Any {
            "placeholder"
        }

        func activityViewController(_: UIActivityViewController, itemForActivityType _: UIActivityType?) -> Any? {
            sharedContent
        }

        func activityViewController(_: UIActivityViewController, subjectForActivityType _: UIActivityType?) -> String {
            "netfox log - \(selectedModel.requestURL!)"
        }
    }

    extension NFXDetailsController_iOS: UITextViewDelegate {
        func textView(_: UITextView, shouldInteractWith URL: URL, in _: NSRange) -> Bool {
            let decodedURL = URL.absoluteString.removingPercentEncoding
            switch decodedURL {
            case "[URL]":
                guard let queryItems = selectedModel.requestURLQueryItems, !queryItems.isEmpty else {
                    return false
                }
                let urlDetailsController = NFXURLDetailsController()
                urlDetailsController.selectedModel = selectedModel
                navigationController?.pushViewController(urlDetailsController, animated: true)
                return true
            default:
                return false
            }
        }
    }

#endif
