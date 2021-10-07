
//
//  Open_SpaceUITests.swift
//  Open SpaceUITests
//
//  Created by Andrew Triboletti on 10/6/21.
//  Copyright © 2021 GreenRobot LLC. All rights reserved.
//

import XCTest

class Open_SpaceUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()
        XCUIApplication()/*@START_MENU_TOKEN@*/.windows["SceneWindow"].windows/*[[".windows[\"Open Space\"]",".groups.windows",".windows",".windows[\"SceneWindow\"]"],[[[-1,3,1],[-1,0,1]],[[-1,2],[-1,1]]],[0,0]]@END_MENU_TOKEN@*/.buttons["Navigate To..."].click()
        XCUIApplication()/*@START_MENU_TOKEN@*/.windows["SceneWindow"].windows/*[[".windows[\"Open Space\"]",".groups.windows",".windows",".windows[\"SceneWindow\"]"],[[[-1,3,1],[-1,0,1]],[[-1,2],[-1,1]]],[0,0]]@END_MENU_TOKEN@*/.buttons["Navigate To..."].click()
        
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}
