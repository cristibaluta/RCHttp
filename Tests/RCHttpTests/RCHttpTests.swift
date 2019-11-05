import XCTest
@testable import RCHttp

final class RCHttpTests: XCTestCase {
    func testError() {
        let err = RCHttpError(errorDescription: "Invalid json response")
        XCTAssert(err.errorDescription == "Invalid json response")
    }

    static var allTests = [
        ("testError", testError),
    ]
}
