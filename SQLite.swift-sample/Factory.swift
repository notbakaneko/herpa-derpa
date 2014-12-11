//
//  ModelFactory.swift
//  SQLite.swift-sample
//
//  Created by bakaneko on 11/12/2014.
//  Copyright (c) 2014 nekonyan. All rights reserved.
//

import Foundation


struct Factory {
    struct ModelFactory {
        static func create() -> Model {
            var model = Model(name: NSUUID().UUIDString)
            model.unique = NSDate().timeIntervalSince1970.description
            return model
        }

        static func create(children count: Int) -> Model {
            var model = Model(name: NSUUID().UUIDString)
            model.unique = NSDate().timeIntervalSince1970.description
            model.save()
            var array = [DetailModel]()
            for i in 0..<count {
                array.append(DetailModelFactory.create(model.id))
            }

            model._details = array
            model.save()

            return model
        }
    }

    struct DetailModelFactory {
        static func create() -> DetailModel {
            var model = DetailModel()

            return model
        }

        static func create(modelId: Int) -> DetailModel {
            var model = DetailModel()
            model.modelId = modelId
            return model
        }
    }
}