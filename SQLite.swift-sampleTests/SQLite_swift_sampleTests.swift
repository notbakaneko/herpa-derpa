//
//  SQLite_swift_sampleTests.swift
//  SQLite.swift-sampleTests
//
//  Created by bakaneko on 9/12/2014.
//  Copyright (c) 2014 nekonyan. All rights reserved.
//

import UIKit
import XCTest

class SQLite_swift_sampleTests: XCTestCase {
    
    override class func setUp() {
        super.setUp()
    }

    override func setUp() {
        super.setUp()
        Model.Storage.createTable()
        DetailModel.Storage.createTable()

        for i in 0...4 {
            Factory.ModelFactory.create(children: 0)
        }
    }

    override func tearDown() {
        super.tearDown()
        Model.Storage.dropTable()
        DetailModel.Storage.dropTable()
    }


    func test_association() {
        if let row = Model.Storage.models.first? {
            let model1 = row.map() as Model
            let model2 = row.map() as Model
            XCTAssertEqual(model1.details.array.count, 0)
            XCTAssertEqual(model2.details.array.count, 0)

            model1.details.array.append(Factory.DetailModelFactory.create())
            model1.save()
            XCTAssertEqual(model1.details.array.count, 1)
            XCTAssertEqual(model2.details.array.count, 0)
            model2.details.reload()
            XCTAssertEqual(model1.details.array.count, 1)
            XCTAssertEqual(model2.details.array.count, 1)
        }
    }

    func test_association_wrappers() {
        if let row = Model.Storage.models.first? {
            let model1 = row.map() as Model
            let model2 = row.map() as Model
            XCTAssertEqual(model1.details.count, 0)
            XCTAssertEqual(model2.details.count, 0)

            model1.details.append(Factory.DetailModelFactory.create())
            model1.save()
            XCTAssertEqual(model1.details.count, 1)
            XCTAssertEqual(model2.details.count, 0)
            model2.details.reload()
            XCTAssertEqual(model1.details.count, 1)
            XCTAssertEqual(model2.details.count, 1)
        }
    }
}
