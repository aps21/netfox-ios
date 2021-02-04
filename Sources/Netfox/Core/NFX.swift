//
// plg
// Copyright © 2021 Heads and Hands. All rights reserved.
//

import Foundation
#if os(OSX)
    import Cocoa
#else
    import UIKit
#endif

private func podPlistVersion() -> String? {
    guard let path = Bundle(identifier: "com.kasketis.netfox-iOS")?.infoDictionary?["CFBundleShortVersionString"] as? String
    else { return nil }
    return path
}

// TODO: Carthage support
let nfxVersion = podPlistVersion() ?? "0"

// Notifications posted when NFX opens/closes, for client application that wish to log that information.
let nfxWillOpenNotification = "NFXWillOpenNotification"
let nfxWillCloseNotification = "NFXWillCloseNotification"

// MARK: - NFX

@objc
open class NFX: NSObject {
    // MARK: Open

    // the sharedInstance class method can be reached from ObjC
    @objc open class func sharedInstance() -> NFX {
        NFX.swiftSharedInstance
    }

    @objc open func start() {
        guard !started else {
            showMessage("Already started!")
            return
        }

        started = true
        register()
        enable()
        clearOldData()
        showMessage("Started!")
        #if os(OSX)
            addNetfoxToMainMenu()
        #endif
    }

    @objc open func stop() {
        unregister()
        disable()
        clearOldData()
        started = false
        showMessage("Stopped!")
        #if os(OSX)
            removeNetfoxFromMainmenu()
        #endif
    }

    @objc open func isStarted() -> Bool {
        started
    }

    @objc open func setCachePolicy(_ policy: URLCache.StoragePolicy) {
        cacheStoragePolicy = policy
    }

    @objc open func setGesture(_ gesture: ENFXGesture) {
        selectedGesture = gesture
        #if os(OSX)
            if gesture == .shake {
                addNetfoxToMainMenu()
            } else {
                removeNetfoxFromMainmenu()
            }
        #endif
    }

    @objc open func show() {
        guard started else { return }
        showNFX()
    }

    @objc open func hide() {
        guard started else { return }
        hideNFX()
    }

    @objc open func toggle() {
        guard started else { return }
        toggleNFX()
    }

    @objc open func ignoreURL(_ url: String) {
        ignoredURLs.append(url)
    }

    // MARK: Public

    @objc public enum ENFXGesture: Int {
        case shake
        case custom
    }

    // MARK: Internal

    #if os(OSX)
        var windowController: NFXWindowController?
        let mainMenu: NSMenu? = NSApp.mainMenu?.items[1].submenu
        var nfxMenuItem = NSMenuItem(
            title: "netfox",
            action: #selector(NFX.show),
            keyEquivalent: String(describing: (character: NSF9FunctionKey, length: 1))
        )
    #endif

    // swiftSharedInstance is not accessible from ObjC
    class var swiftSharedInstance: NFX {
        enum Singleton {
            static let instance = NFX()
        }
        return Singleton.instance
    }

    internal var cacheStoragePolicy = URLCache.StoragePolicy.notAllowed

    internal func isEnabled() -> Bool {
        enabled
    }

    internal func enable() {
        enabled = true
    }

    internal func disable() {
        enabled = false
    }

    @objc func motionDetected() {
        guard started else { return }
        toggleNFX()
    }

    internal func getLastVisitDate() -> Date {
        lastVisitDate
    }

    internal func clearOldData() {
        NFXHTTPModelManager.sharedInstance.clear()
        do {
            let documentsPath = NSSearchPathForDirectoriesInDomains(
                FileManager.SearchPathDirectory.documentDirectory,
                FileManager.SearchPathDomainMask.allDomainsMask,
                true
            ).first!
            let filePathsArray = try FileManager.default.subpathsOfDirectory(atPath: documentsPath)
            for filePath in filePathsArray {
                if filePath.hasPrefix("nfx") {
                    try FileManager.default.removeItem(atPath: (documentsPath as NSString).appendingPathComponent(filePath))
                }
            }

            try FileManager.default.removeItem(atPath: NFXPath.SessionLog)
        } catch {}
    }

    func getIgnoredURLs() -> [String] {
        ignoredURLs
    }

    func getSelectedGesture() -> ENFXGesture {
        selectedGesture
    }

    func cacheFilters(_ selectedFilters: [Bool]) {
        filters = selectedFilters
    }

    func getCachedFilters() -> [Bool] {
        if filters.isEmpty {
            filters = [Bool](repeating: true, count: HTTPModelShortType.allValues.count)
        }
        return filters
    }

    // MARK: Fileprivate

    fileprivate var started: Bool = false
    fileprivate var presented: Bool = false
    fileprivate var enabled: Bool = false
    fileprivate var selectedGesture: ENFXGesture = .shake
    fileprivate var ignoredURLs = [String]()
    fileprivate var filters = [Bool]()
    fileprivate var lastVisitDate = Date()

    fileprivate func showMessage(_ msg: String) {
        print("netfox \(nfxVersion) - [https://github.com/kasketis/netfox]: \(msg)")
    }

    fileprivate func register() {
        URLProtocol.registerClass(NFXProtocol.self)
    }

    fileprivate func unregister() {
        URLProtocol.unregisterClass(NFXProtocol.self)
    }

    fileprivate func showNFX() {
        if presented {
            return
        }

        showNFXFollowingPlatform()
        presented = true
    }

    fileprivate func hideNFX() {
        if !presented {
            return
        }

        NotificationCenter.default.post(name: Notification.Name.NFXDeactivateSearch, object: nil)
        hideNFXFollowingPlatform { () -> Void in
            self.presented = false
            self.lastVisitDate = Date()
        }
    }

    fileprivate func toggleNFX() {
        presented ? hideNFX() : showNFX()
    }
}

#if os(iOS)

    fileprivate extension NFX {
        var presentingViewController: UIViewController? {
            var rootViewController = UIApplication.shared.keyWindow?.rootViewController
            while let controller = rootViewController?.presentedViewController {
                rootViewController = controller
            }
            return rootViewController
        }

        func showNFXFollowingPlatform() {
            let navigationController = UINavigationController(rootViewController: NFXListController_iOS())
            navigationController.navigationBar.isTranslucent = false
            navigationController.navigationBar.tintColor = UIColor.NFXOrangeColor()
            navigationController.navigationBar.barTintColor = UIColor.NFXStarkWhiteColor()
            navigationController.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.NFXOrangeColor()]

            if #available(iOS 13.0, *) {
                navigationController.presentationController?.delegate = self
            }

            presentingViewController?.present(navigationController, animated: true, completion: nil)
        }

        func hideNFXFollowingPlatform(_ completion: (() -> Void)?) {
            presentingViewController?.dismiss(animated: true, completion: { () -> Void in
                if let notNilCompletion = completion {
                    notNilCompletion()
                }
            })
        }
    }

    extension NFX: UIAdaptivePresentationControllerDelegate {
        public func presentationControllerDidDismiss(_: UIPresentationController) {
            guard started else { return }
            presented = false
        }
    }

#elseif os(OSX)

    public extension NFX {
        func windowDidClose() {
            presented = false
        }

        private func setupNetfoxMenuItem() {
            nfxMenuItem.target = self
            nfxMenuItem.action = #selector(NFX.motionDetected)
            nfxMenuItem.keyEquivalent = "n"
            nfxMenuItem.keyEquivalentModifierMask = NSEvent
                .ModifierFlags(rawValue: UInt(Int(NSEvent.ModifierFlags.command.rawValue | NSEvent.ModifierFlags.shift.rawValue)))
        }

        func addNetfoxToMainMenu() {
            setupNetfoxMenuItem()
            if let menu = mainMenu {
                menu.insertItem(nfxMenuItem, at: 0)
            }
        }

        func removeNetfoxFromMainmenu() {
            if let menu = mainMenu {
                menu.removeItem(nfxMenuItem)
            }
        }

        func showNFXFollowingPlatform() {
            if windowController == nil {
                #if swift(>=4.2)
                    let nibName = "NetfoxWindow"
                #else
                    let nibName = NSNib.Name(rawValue: "NetfoxWindow")
                #endif

                windowController = NFXWindowController(windowNibName: nibName)
            }
            windowController?.showWindow(nil)
        }

        func hideNFXFollowingPlatform(completion: (() -> Void)?) {
            windowController?.close()
            if let notNilCompletion = completion {
                notNilCompletion()
            }
        }
    }

#endif
