import XCTest
@testable import SebbuKit

final class SebbuKitTests: XCTestCase {
    func testNetworkUtils() {
        //TODO: Fix this test for Windows once we have implemented NetworkUtils
        #if !os(Windows)
        let ipAddress = NetworkUtils.publicIP
        
        XCTAssert(ipAddress != nil, "IP Address was nil")
        XCTAssert(ipAddress!.range(of: #"\b^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$\b"#,
        options: .regularExpression) != nil, "IP Address: \(ipAddress!), regex failed!")
        #endif
    }

    static var allTests = [
        ("testNetworkUtils", testNetworkUtils),
    ]
}
