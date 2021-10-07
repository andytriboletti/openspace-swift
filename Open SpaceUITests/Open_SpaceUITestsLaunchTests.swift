//
//  Open_SpaceUITestsLaunchTests.swift
//  Open SpaceUITests
//
//  Created by Andrew Triboletti on 10/6/21.
//  Copyright © 2021 GreenRobot LLC. All rights reserved.
//

import XCTest

class Open_SpaceUITestsLaunchTests: XCTestCase {

    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        true
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testLaunch() throws {
        let app = XCUIApplication()
        app.launch()

        // Insert steps here to perform after app launch but before taking a screenshot,
        // such as logging into a test account or navigating somewhere in the app

        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Launch Screen"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
