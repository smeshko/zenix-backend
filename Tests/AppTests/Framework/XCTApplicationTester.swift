import XCTVapor

extension XCTApplicationTester {

    @discardableResult public func test<T>(
        _ method: HTTPMethod,
        _ path: String,
        headers: HTTPHeaders = [:],
        token: String? = nil,
        content: T,
        afterResponse: (XCTHTTPResponse) throws -> () = { _ in }
    ) throws -> XCTApplicationTester where T: Content {
        try test(method, path, headers: headers, beforeRequest: { req in
            try req.content.encode(content)
            if let token {
                req.headers.add(name: "Authorization", value: "Bearer \(token)")
            }
        }, afterResponse: afterResponse)
    }
}
