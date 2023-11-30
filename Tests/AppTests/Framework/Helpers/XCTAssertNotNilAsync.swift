import XCTVapor

func XCTAssertNotNilAsync(_ expression: @autoclosure () async throws -> Any?) async throws {
    let result = try await expression()
    XCTAssertNotNil(result)
}

func XCTUnwrapAsync<T>(_ expression: @autoclosure () async throws -> T?) async throws -> T {
    let result = try await expression()
    return try XCTUnwrap(result)
}
