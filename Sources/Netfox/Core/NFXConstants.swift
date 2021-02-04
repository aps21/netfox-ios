//
// plg
// Copyright © 2021 Heads and Hands. All rights reserved.
//

#if os(iOS)
    import UIKit

    typealias NFXColor = UIColor
    typealias NFXFont = UIFont
    typealias NFXImage = UIImage
    typealias NFXViewController = UIViewController

#elseif os(OSX)
    import Cocoa

    typealias NFXColor = NSColor
    typealias NFXFont = NSFont
    typealias NFXImage = NSImage
    typealias NFXViewController = NSViewController
#endif
