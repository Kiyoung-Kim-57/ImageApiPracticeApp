//
//  ImageListAppTests.swift
//  ImageListAppTests
//
//  Created by 김기영 on 12/10/24.
//

import XCTest

final class ImageListAppTests: XCTestCase {

    func test_api_키호출() {
        let apiKey = Bundle.main.apiKey
        
        XCTAssertNotNil(apiKey)
    }
}
