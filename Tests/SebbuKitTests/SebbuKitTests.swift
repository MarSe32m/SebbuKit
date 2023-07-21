import XCTest
import SebbuKit
import Crypto

final class SebbuKitTests: XCTestCase {
    func testNetworkUtils() {
        let ipAddress = NetworkUtils.publicIP
        XCTAssert(ipAddress != nil, "IP Address was nil")
        XCTAssert(ipAddress!.isIpAddress)
    }
    
    @available(iOS 13.2, *)
    func testHMAC256SignatureAndVerification() {
        let key = SymmetricKey(size: .bits256)
        let data = "Hello this data is some test data... We are now going to make a signature out of it".hexBytes
        let signature = HMACSHA256Signature(data, key: key)
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
    
    func testLowestSetBit() {
        var int = 0
        for i in 0..<64 {
            int <<= i
            XCTAssertEqual(int, int.lowestSetBit)
        }
        let powersOfTwo = (0..<64).map { i in 1 << i}
        var result: [Int] = []
        var number = ~0
        while number != 0 {
            let lsb = number.lowestSetBit
            number &= ~lsb
            result.append(lsb)
        }
        XCTAssertEqual(powersOfTwo, result)
        XCTAssertEqual(powersOfTwo, (~0).powersOfTwo().map {$0})
    }

    func testRunLoopOnce() async {
        let task = Task.detached { @MainActor in 
            return 1
        }
        RunLoop.main.runOnce()
        let value = await task.value
        XCTAssertEqual(1, value)
    }
    
    func testUTF8StringUtilities() {
        let validUTF8: [UInt8] = [0x43, 0x61, 0x66, 0xC3, 0xA9]
        let invalidUTF8: [UInt8] = [0x43, 0x61, 0x66, 0xC3]
        
        let validString = String(fromUtf8: validUTF8)
        XCTAssertEqual(validString, "Café")
        
        let invalidString = String(fromUtf8: invalidUTF8)
        XCTAssertEqual(invalidString, "Caf\u{FFFD}")
    }
}
