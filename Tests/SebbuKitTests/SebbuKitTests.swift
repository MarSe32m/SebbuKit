import XCTest
import SebbuKit
import Crypto

final class SebbuKitTests: XCTestCase {
    func testNetworkUtils() {
        let ipAddress = NetworkUtils.publicIP
        XCTAssert(ipAddress != nil, "IP Address was nil")
        XCTAssert(ipAddress!.isIpAddress())
    }
    
    func testHMAC256SignatureAndVerification() {
        let key = SymmetricKey(size: .bits256)
        let data = "Hello this data is some test data... We are now going to make a signature out of it".hexBytes
        let signature = HMACSHA256Signature(data, key: key)
        let otherSignature = HMACSHA256Signature(data, key: key)
        XCTAssert(HMACSHA256Verify(data, signature: signature, key: key), "Verification failed")
        XCTAssertFalse(HMACSHA256Verify(data + [1], signature: signature, key: key), "Verification succeeded?")
        XCTAssertFalse(HMACSHA256Verify(data, signature: signature + [1], key: key), "Verification succeeded?")
        XCTAssertFalse(HMACSHA256Verify(data + [1], signature: signature + [1], key: key), "Verification succeeded?")
    }
    
    func testBCrypt() throws {
        let password = "This is some super secret password*******12351234"
        let hash = try BCrypt.hash(password)
        XCTAssert(try BCrypt.verify(password, created: hash))
        XCTAssertFalse(try BCrypt.verify("This is some super secret password thats wrong", created: hash))
    }
}
