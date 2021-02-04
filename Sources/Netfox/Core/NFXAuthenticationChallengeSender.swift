//
// plg
// Copyright © 2021 Heads and Hands. All rights reserved.
//

import Foundation

class NFXAuthenticationChallengeSender: NSObject, URLAuthenticationChallengeSender {
    // MARK: Lifecycle

    init(handler: @escaping NFXAuthenticationChallengeHandler) {
        self.handler = handler
        super.init()
    }

    // MARK: Internal

    typealias NFXAuthenticationChallengeHandler = (URLSession.AuthChallengeDisposition, URLCredential?) -> Void

    let handler: NFXAuthenticationChallengeHandler

    func use(_ credential: URLCredential, for _: URLAuthenticationChallenge) {
        handler(.useCredential, credential)
    }

    func continueWithoutCredential(for _: URLAuthenticationChallenge) {
        handler(.useCredential, nil)
    }

    func cancel(_: URLAuthenticationChallenge) {
        handler(.cancelAuthenticationChallenge, nil)
    }

    func performDefaultHandling(for _: URLAuthenticationChallenge) {
        handler(.performDefaultHandling, nil)
    }

    func rejectProtectionSpaceAndContinue(with _: URLAuthenticationChallenge) {
        handler(.rejectProtectionSpace, nil)
    }
}
