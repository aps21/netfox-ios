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

// MARK: - HTTPModelShortType

public enum HTTPModelShortType: String {
    case JSON
    case XML
    case HTML
    case IMAGE = "Image"
    case OTHER = "Other"

    // MARK: Internal

    static let allValues = [JSON, XML, HTML, IMAGE, OTHER]
}

extension NFXColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")

        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }

    convenience init(netHex: Int) {
        self.init(red: (netHex >> 16) & 0xFF, green: (netHex >> 8) & 0xFF, blue: netHex & 0xFF)
    }

    class func NFXOrangeColor() -> NFXColor {
        NFXColor(netHex: 0xEC5E28)
    }

    class func NFXGreenColor() -> NFXColor {
        NFXColor(netHex: 0x38BB93)
    }

    class func NFXDarkGreenColor() -> NFXColor {
        NFXColor(netHex: 0x2D7C6E)
    }

    class func NFXRedColor() -> NFXColor {
        NFXColor(netHex: 0xD34A33)
    }

    class func NFXDarkRedColor() -> NFXColor {
        NFXColor(netHex: 0x643026)
    }

    class func NFXStarkWhiteColor() -> NFXColor {
        NFXColor(netHex: 0xCCC5B9)
    }

    class func NFXDarkStarkWhiteColor() -> NFXColor {
        NFXColor(netHex: 0x9B958D)
    }

    class func NFXLightGrayColor() -> NFXColor {
        NFXColor(netHex: 0x9B9B9B)
    }

    class func NFXGray44Color() -> NFXColor {
        NFXColor(netHex: 0x707070)
    }

    class func NFXGray95Color() -> NFXColor {
        NFXColor(netHex: 0xF2F2F2)
    }

    class func NFXBlackColor() -> NFXColor {
        NFXColor(netHex: 0x231F20)
    }
}

extension NFXFont {
    #if os(iOS)
        class func NFXFont(size: CGFloat) -> UIFont {
            UIFont(name: "HelveticaNeue", size: size)!
        }

        class func NFXFontBold(size: CGFloat) -> UIFont {
            UIFont(name: "HelveticaNeue-Bold", size: size)!
        }

    #elseif os(OSX)
        class func NFXFont(size: CGFloat) -> NSFont {
            NSFont(name: "HelveticaNeue", size: size)!
        }

        class func NFXFontBold(size: CGFloat) -> NSFont {
            NSFont(name: "HelveticaNeue-Bold", size: size)!
        }
    #endif
}

extension URLRequest {
    func getNFXURL() -> String {
        if url != nil {
            return url!.absoluteString
        } else {
            return "-"
        }
    }

    func getNFXURLComponents() -> URLComponents? {
        guard let url = self.url else {
            return nil
        }
        return URLComponents(string: url.absoluteString)
    }

    func getNFXMethod() -> String {
        if httpMethod != nil {
            return httpMethod!
        } else {
            return "-"
        }
    }

    func getNFXCachePolicy() -> String {
        switch cachePolicy {
        case .useProtocolCachePolicy: return "UseProtocolCachePolicy"
        case .reloadIgnoringLocalCacheData: return "ReloadIgnoringLocalCacheData"
        case .reloadIgnoringLocalAndRemoteCacheData: return "ReloadIgnoringLocalAndRemoteCacheData"
        case .returnCacheDataElseLoad: return "ReturnCacheDataElseLoad"
        case .returnCacheDataDontLoad: return "ReturnCacheDataDontLoad"
        case .reloadRevalidatingCacheData: return "ReloadRevalidatingCacheData"
        @unknown default: return "Unknown \(cachePolicy)"
        }
    }

    func getNFXTimeout() -> String {
        String(Double(timeoutInterval))
    }

    func getNFXHeaders() -> [AnyHashable: Any] {
        if allHTTPHeaderFields != nil {
            return allHTTPHeaderFields!
        } else {
            return Dictionary()
        }
    }

    func getNFXBody() -> Data {
        httpBodyStream?.readfully() ?? URLProtocol.property(forKey: "NFXBodyData", in: self) as? Data ?? Data()
    }

    func getCurl() -> String {
        guard let url = url else { return "" }
        let baseCommand = "curl \(url.absoluteString)"

        var command = [baseCommand]

        if let method = httpMethod {
            command.append("-X \(method)")
        }

        for (key, value) in getNFXHeaders() {
            command.append("-H \u{22}\(key): \(value)\u{22}")
        }

        if let body = String(data: getNFXBody(), encoding: .utf8) {
            command.append("-d \u{22}\(body)\u{22}")
        }

        return command.joined(separator: " ")
    }
}

extension URLResponse {
    func getNFXStatus() -> Int {
        (self as? HTTPURLResponse)?.statusCode ?? 999
    }

    func getNFXHeaders() -> [AnyHashable: Any] {
        (self as? HTTPURLResponse)?.allHeaderFields ?? [:]
    }
}

extension NFXImage {
    class func NFXSettings() -> NFXImage {
        #if os(iOS)
            return UIImage(data: NFXAssets.getImage(NFXAssetName.settings), scale: 1.7)!
        #elseif os(OSX)
            return NSImage(data: NFXAssets.getImage(NFXAssetName.settings))!
        #endif
    }

    class func NFXClose() -> NFXImage {
        #if os(iOS)
            return UIImage(data: NFXAssets.getImage(NFXAssetName.close), scale: 1.7)!
        #elseif os(OSX)
            return NSImage(data: NFXAssets.getImage(NFXAssetName.close))!
        #endif
    }

    class func NFXInfo() -> NFXImage {
        #if os(iOS)
            return UIImage(data: NFXAssets.getImage(NFXAssetName.info), scale: 1.7)!
        #elseif os(OSX)
            return NSImage(data: NFXAssets.getImage(NFXAssetName.info))!
        #endif
    }

    class func NFXStatistics() -> NFXImage {
        #if os(iOS)
            return UIImage(data: NFXAssets.getImage(NFXAssetName.statistics), scale: 1.7)!
        #elseif os(OSX)
            return NSImage(data: NFXAssets.getImage(NFXAssetName.statistics))!
        #endif
    }
}

extension InputStream {
    func readfully() -> Data {
        var result = Data()
        var buffer = [UInt8](repeating: 0, count: 4096)

        open()

        var amount = 0
        repeat {
            amount = read(&buffer, maxLength: buffer.count)
            if amount > 0 {
                result.append(buffer, count: amount)
            }
        } while amount > 0

        close()

        return result
    }
}

extension Date {
    func isGreaterThanDate(_ dateToCompare: Date) -> Bool {
        if compare(dateToCompare) == ComparisonResult.orderedDescending {
            return true
        } else {
            return false
        }
    }
}

// MARK: - NFXDebugInfo

class NFXDebugInfo {
    class func getNFXAppName() -> String {
        Bundle.main.infoDictionary?["CFBundleName"] as? String ?? ""
    }

    class func getNFXAppVersionNumber() -> String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
    }

    class func getNFXAppBuildNumber() -> String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? ""
    }

    class func getNFXBundleIdentifier() -> String {
        Bundle.main.bundleIdentifier ?? ""
    }

    class func getNFXOSVersion() -> String {
        #if os(iOS)
            return UIDevice.current.systemVersion
        #elseif os(OSX)
            return ProcessInfo.processInfo.operatingSystemVersionString
        #endif
    }

    class func getNFXDeviceType() -> String {
        #if os(iOS)
            return UIDevice.getNFXDeviceType()
        #elseif os(OSX)
            return "Not implemented yet. PR welcomes"
        #endif
    }

    class func getNFXDeviceScreenResolution() -> String {
        #if os(iOS)
            let scale = UIScreen.main.scale
            let bounds = UIScreen.main.bounds
            let width = bounds.size.width * scale
            let height = bounds.size.height * scale
            return "\(width) x \(height)"
        #elseif os(OSX)
            return "0"
        #endif
    }

    class func getNFXIP(_ completion: @escaping (_ result: String) -> Void) {
        var req: NSMutableURLRequest
        req = NSMutableURLRequest(url: URL(string: "https://api.ipify.org/?format=json")!)
        URLProtocol.setProperty("1", forKey: "NFXInternal", in: req)

        let session = URLSession.shared
        session.dataTask(with: req as URLRequest, completionHandler: { data, _, _ in
            do {
                let rawJsonData = try JSONSerialization.jsonObject(with: data!, options: [.allowFragments])
                if let ipAddress = (rawJsonData as AnyObject).value(forKey: "ip") {
                    completion(ipAddress as! String)
                } else {
                    completion("-")
                }
            } catch {
                completion("-")
            }

        }).resume()
    }
}

// MARK: - NFXPath

enum NFXPath {
    static let Documents = NSSearchPathForDirectoriesInDomains(
        FileManager.SearchPathDirectory.documentDirectory,
        FileManager.SearchPathDomainMask.allDomainsMask,
        true
    ).first! as NSString

    static let SessionLog = NFXPath.Documents.appendingPathComponent("session.log")
}

extension String {
    func appendToFile(filePath: String) {
        let contentToAppend = self

        if let fileHandle = FileHandle(forWritingAtPath: filePath) {
            /* Append to file */
            fileHandle.seekToEndOfFile()
            fileHandle.write(contentToAppend.data(using: String.Encoding.utf8)!)
        } else {
            /* Create new file */
            do {
                try contentToAppend.write(toFile: filePath, atomically: true, encoding: String.Encoding.utf8)
            } catch {
                print("Error creating \(filePath)")
            }
        }
    }
}

public extension NSNotification.Name {
    static let NFXDeactivateSearch = Notification.Name("NFXDeactivateSearch")
    static let NFXReloadData = Notification.Name("NFXReloadData")
    static let NFXAddedModel = Notification.Name("NFXAddedModel")
    static let NFXClearedModels = Notification.Name("NFXClearedModels")
}
