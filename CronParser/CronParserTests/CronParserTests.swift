//
//  CronParserTests.swift
//  CronParserTests
//
//  Created by Jamie Kelly on 14/08/2022.
//

import XCTest
@testable import CronParser

class CronParserTests: XCTestCase {

    let script = Script()
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    var data: [TestDataItem] = [
        TestDataItem(config: "30 13 /bin/case1", time: "13:30", desiredOutput: "13:30 today /bin/case1"),
        TestDataItem(config: "45 * /bin/case2", time: "10:34", desiredOutput: "10:45 today /bin/case2"),
        TestDataItem(config: "* * /bin/case3", time: "23:59", desiredOutput: "23:59 today /bin/case3"),
        TestDataItem(config: "* 19 /bin/case4", time: "12:20", desiredOutput: "19:00 today /bin/case4"),
        TestDataItem(config: "* 00 /bin/case5", time: "00:20", desiredOutput: "00:20 today /bin/case5"),
        TestDataItem(config: "59 23 /bin/case6", time: "00:00", desiredOutput: "23:59 today /bin/case6"),
        TestDataItem(config: "58 23 /bin/case7", time: "23:59", desiredOutput: "23:58 tomorrow /bin/case7"),
        TestDataItem(config: "00 12 /bin/case8", time: "12:01", desiredOutput: "12:00 tomorrow /bin/case8"),
        TestDataItem(config: "00 12 /bin/case9", time: "12:01", desiredOutput: "12:00 tomorrow /bin/case9"),
        TestDataItem(config: "00 12 /bin/case10", time: "12:59", desiredOutput: "12:00 tomorrow /bin/case10"),
        TestDataItem(config: "* 0 /bin/case11", time: "1:59", desiredOutput: "00:00 tomorrow /bin/case11"),
        TestDataItem(config: "1 0 /bin/case12", time: "0:02", desiredOutput: "00:01 tomorrow /bin/case12"),
    ]
    
    struct TestDataItem {
        let config: String
        let time: String
        let desiredOutput: String
    }

    func testExampleData() throws {
        for item in data {
            if let result = script.processLines([item.config], time: item.time)?.first {
                XCTAssert(result.displayString == item.desiredOutput, "FAILED: \(result.displayString) ---VS--- \(item.desiredOutput)")
            }
            else {
                XCTAssert(true)
            }
        }
    }

}
