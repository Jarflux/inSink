//
//  InSinkTests.swift
//  InSinkTests
//
//  Created by Ben Oeyen on 06/05/16.
//  Copyright © 2016 Ben Oeyen. All rights reserved.
//

import XCTest
@testable import InSink

class InSinkTests: XCTestCase {
    
    var viewController :ViewController!;
    
    override func setUp() {
        super.setUp()
        viewController = ViewController()
        viewController.debug = false
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testSimpleExtensionsCheck() {
        viewController.extensions = ["html"]
        let path = "/User/Ben/jcr_root/content/test.html"
        XCTAssertTrue(viewController.hasCorrectExtension(path))
    }
    
    func testSimpleExtensionsCheckNotFound() {
        viewController.extensions = ["html"]
        let path = "/User/Ben/jcr_root/content/test.css"
        XCTAssertFalse(viewController.hasCorrectExtension(path))
    }
    
    func testMultiExtensionsCheck() {
        viewController.extensions = ["html", "css"]
        let path = "/User/Ben/jcr_root/content/test.html"
        XCTAssertTrue(viewController.hasCorrectExtension(path))
    }
    
    func testMultiExtensionsCheckNotFound() {
        viewController.extensions = ["html", "css"]
        let path = "/User/Ben/jcr_root/content/test.js"
        XCTAssertFalse(viewController.hasCorrectExtension(path))
    }
    
    func testPathContainsJcrRootCheck() {
        let path = "/User/Ben/jcr_root/content/test.html"
        XCTAssertTrue(viewController.pathContainsJrcRoot(path))
    }
    
    func testPathContainsJcrRootCheckNotFound() {
        let path = "/User/Ben/jcr_roo/content/test.js"
        XCTAssertFalse(viewController.pathContainsJrcRoot(path))
    }
    
    func testGetJcrPath() {
        let path = "/User/Ben/jcr_root/content/test.html"
        XCTAssertEqual(viewController.getJrcPath(path), "/content/test.html")
    }
    
    func testEventIsNotHandledCheck() {
        viewController.lastProcessedId = 15
        XCTAssertTrue(viewController.eventIsNotHandledBefore(16))
    }
    
    func testEventIsAlreadyHandledCheck() {
        viewController.lastProcessedId = 15
        XCTAssertFalse(viewController.eventIsNotHandledBefore(10))
    }
    
    func testParseInputSingle() {
        XCTAssertEqual(viewController.parseInput("html"), ["html"])
    }
    
    func testParseInputMulti() {
        XCTAssertEqual(viewController.parseInput("html,css"), ["html","css"])
    }
    
    func testParseInputMultiWithSpaces() {
        XCTAssertEqual(viewController.parseInput("html , css "), ["html","css"])
    }
    
    func testParseInputMultiWithSpacesAndDot() {
        XCTAssertEqual(viewController.parseInput("html, .css "), ["html","css"])
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
    
}
