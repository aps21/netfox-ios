//
// plg
// Copyright © 2021 Heads and Hands. All rights reserved.
//

import Foundation

// MARK: - NFXProtocol

@objc
open class NFXProtocol: URLProtocol {
    // MARK: Open

    override open class func canInit(with request: URLRequest) -> Bool {
        canServeRequest(request)
    }

    override open class func canInit(with task: URLSessionTask) -> Bool {
        guard let request = task.currentRequest else { return false }
        return canServeRequest(request)
    }

    override open class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override open func startLoading() {
        model.saveRequest(request)

        let mutableRequest = (request as NSURLRequest).mutableCopy() as! NSMutableURLRequest
        URLProtocol.setProperty(true, forKey: NFXProtocol.nfxInternalKey, in: mutableRequest)
        session.dataTask(with: mutableRequest as URLRequest).resume()
    }

    override open func stopLoading() {
        session.getTasksWithCompletionHandler { dataTasks, _, _ in
            dataTasks.forEach { $0.cancel() }
        }
    }

    // MARK: Private

    private static let nfxInternalKey = "com.netfox.NFXInternal"

    private lazy var session: URLSession = { [unowned self] in
        URLSession(configuration: .default, delegate: self, delegateQueue: nil)
    }()

    private let model = NFXHTTPModel()
    private var response: URLResponse?
    private var responseData: NSMutableData?

    private class func canServeRequest(_ request: URLRequest) -> Bool {
        guard NFX.sharedInstance().isEnabled() else {
            return false
        }

        guard
            URLProtocol.property(forKey: NFXProtocol.nfxInternalKey, in: request) == nil,
            let url = request.url,
            url.absoluteString.hasPrefix("http") || url.absoluteString.hasPrefix("https")
        else {
            return false
        }

        let absoluteString = url.absoluteString
        guard !NFX.sharedInstance().getIgnoredURLs().contains(where: { absoluteString.hasPrefix($0) }) else {
            return false
        }

        return true
    }
}

// MARK: URLSessionDataDelegate

extension NFXProtocol: URLSessionDataDelegate {
    public func urlSession(_: URLSession, dataTask _: URLSessionDataTask, didReceive data: Data) {
        responseData?.append(data)

        client?.urlProtocol(self, didLoad: data)
    }

    public func urlSession(
        _: URLSession,
        dataTask _: URLSessionDataTask,
        didReceive response: URLResponse,
        completionHandler: @escaping (URLSession.ResponseDisposition) -> Void
    ) {
        self.response = response
        responseData = NSMutableData()

        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: NFX.swiftSharedInstance.cacheStoragePolicy)
        completionHandler(.allow)
    }

    public func urlSession(_: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        defer {
            if let error = error {
                client?.urlProtocol(self, didFailWithError: error)
            } else {
                client?.urlProtocolDidFinishLoading(self)
            }
        }

        guard let request = task.originalRequest else {
            return
        }

        model.saveRequestBody(request)
        model.logRequest(request)

        if error != nil {
            model.saveErrorResponse()
        } else if let response = response {
            let data = (responseData ?? NSMutableData()) as Data
            model.saveResponse(response, data: data)
        }

        NFXHTTPModelManager.sharedInstance.add(model)
        NotificationCenter.default.post(name: .NFXReloadData, object: nil)
    }

    public func urlSession(
        _: URLSession,
        task _: URLSessionTask,
        willPerformHTTPRedirection response: HTTPURLResponse,
        newRequest request: URLRequest,
        completionHandler: @escaping (URLRequest?) -> Void
    ) {
        let updatedRequest: URLRequest
        if URLProtocol.property(forKey: NFXProtocol.nfxInternalKey, in: request) != nil {
            let mutableRequest = (request as NSURLRequest).mutableCopy() as! NSMutableURLRequest
            URLProtocol.removeProperty(forKey: NFXProtocol.nfxInternalKey, in: mutableRequest)

            updatedRequest = mutableRequest as URLRequest
        } else {
            updatedRequest = request
        }

        client?.urlProtocol(self, wasRedirectedTo: updatedRequest, redirectResponse: response)
        completionHandler(updatedRequest)
    }

    public func urlSession(
        _: URLSession,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        let wrappedChallenge = URLAuthenticationChallenge(
            authenticationChallenge: challenge,
            sender: NFXAuthenticationChallengeSender(handler: completionHandler)
        )
        client?.urlProtocol(self, didReceive: wrappedChallenge)
    }

    #if !os(OSX)
        public func urlSessionDidFinishEvents(forBackgroundURLSession _: URLSession) {
            client?.urlProtocolDidFinishLoading(self)
        }
    #endif
}
