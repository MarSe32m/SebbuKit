import XCTest
@testable import SebbuKit

final class SebbuKitTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(SebbuKit().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
