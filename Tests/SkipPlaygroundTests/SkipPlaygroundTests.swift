import XCTest
import OSLog
import Foundation
@testable import SkipPlayground

let logger: Logger = Logger(subsystem: "SkipPlayground", category: "Tests")

@available(macOS 13, *)
final class SkipPlaygroundTests: XCTestCase {

    func testSkipPlayground() throws {
        logger.log("running testSkipPlayground")
        XCTAssertEqual(1 + 2, 3, "basic test")
    }

    func testDecodeType() throws {
        // load the TestData.json file from the Resources folder and decode it into a struct
        let resourceURL: URL = try XCTUnwrap(Bundle.module.url(forResource: "TestData", withExtension: "json"))
        let testData = try JSONDecoder().decode(TestData.self, from: Data(contentsOf: resourceURL))
        XCTAssertEqual("SkipPlayground", testData.testModuleName)
    }

    func testMockRuntimeNormalize() {
        XCTAssertEqual(MockRuntime.normalize(identifier: "  Demo-1  "), "demo-1")
    }

    func testMockRuntimeClientRefs() {
        let refs = MockRuntime.makeClientRefs(prefix: "item", count: 3)
        XCTAssertEqual(refs, ["item:0", "item:1", "item:2"])
    }
}

struct TestData : Codable, Hashable {
    var testModuleName: String
}
