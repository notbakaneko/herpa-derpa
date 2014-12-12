//
//  Model.swift
//  SQLite.swift-sample
//
//  Created by bakaneko on 9/12/2014.
//  Copyright (c) 2014 nekonyan. All rights reserved.
//

import Foundation
import SQLite


let db = Database()

protocol ModelType {
    init(row: Row)

    func save()
    func delete(#cascade: Bool) -> Int?
    func delete() -> Int?
}

protocol GenericModelType: ModelType {
    typealias T
}

class Base: GenericModelType {
    typealias T = Base
    typealias PrimaryKeyType = Int

    var primaryKeyValue: PrimaryKeyType {
        assert(1 == 0, "Must override")
        return 0
    }

    init () {}

    required init(row: Row) {

    }

    func save() {
        if primaryKeyValue > 0 {
            _update()
        } else {
            _insert()
        }

        _cascadingUpdate()
    }

    func delete(#cascade: Bool) -> Int? {
        if cascade {
            _cascadingDelete()
        }

        return _delete()
    }

    func delete() -> Int? {
        return delete(cascade: true)
    }


    // MARK:- implementation
    func _update() {
        assert(1 == 0, "Must override")
    }

    func _insert() {
        assert(1 == 0, "Must override")
    }

    func _cascadingUpdate() {
//        assert(1 == 0, "Must override")
    }

    func _delete() -> Int? {
        assert(1 == 0, "Must override")
    }

    func _cascadingDelete() -> Int? {
//        assert(1 == 0, "Must override")
        return 0
    }
}

class Model: Base {
    typealias T = Model
    typealias PrimaryKeyType = Int
    override var primaryKeyValue: PrimaryKeyType {
        return id
    }

    var id = 0
    var name: String
    var unique: String = ""
    var optional: String?
    var _details: [DetailModel]?
    var details: [DetailModel] {
        get {
            if (_details != nil) {
                return _details!
            }

            let query = DetailModel.Storage.models.filter(DetailModel.Storage.modelId == id)
            _details = query.map()
            return _details!
        }
    }

    init(name: String) {
        self.name = name
        super.init()
    }

    required init(row: Row) {
        self.id = row[Storage.id]
        self.name = row[Storage.name]
        self.unique = row[Storage.unique]
        self.optional = row[Storage.optional]
        super.init()
    }


    struct Storage {
        static let models = db["models"]
        static let id = Expression<Int>("id")
        static let name = Expression<String>("name")
        static let unique = Expression<String>("unique")
        static let optional = Expression<String?>("optional")


        static func createTable() {
            db.create(table: models) { t in
                t.column(self.id, primaryKey: true)
                t.column(self.name)
                t.column(self.unique, unique: true)
                t.column(self.optional)
            }
        }
    }


    override func _update() {
        if let result = Storage.models.filter(Storage.id == id).update(
            Storage.name <- name,
            Storage.unique <- unique,
            Storage.optional <- optional) {
                debugPrintln(result)
        }
    }

    override func _insert() {
        if let insertedId = Storage.models.insert(
            Storage.name <- name,
            Storage.unique <- unique,
            Storage.optional <- optional) {
                debugPrintln(insertedId)
                id = insertedId
        } else {
            debugPrint("Cannot insert Model with id: \(id)")
        }
    }

    override func _cascadingUpdate() {
        if let details = _details {
            for detail in details {
                detail.modelId = id
                detail.save()
            }
        }
    }

    override func _delete() -> Int? {
        let count = Storage.models.filter(Storage.id == id).delete()?
        debugPrintln("id: \(id), \(count) rows deleted")
        return count
    }

    override func _cascadingDelete() -> Int? {
        if let count = DetailModel.Storage.models.filter(DetailModel.Storage.modelId == id).delete()? {
            debugPrintln("id: \(id), \(count) nested rows deleted")
            return count
        }

        return nil
    }
}


class DetailModel: Base {
    typealias T = DetailModel
    typealias PrimaryKeyType = Int
    override var primaryKeyValue: PrimaryKeyType {
        return id
    }

    var id = 0
    var modelId = 0

    override init() {
        super.init()
    }

    required init(row: Row) {
        self.id = row[Storage.id]
        self.modelId = row[Storage.modelId]
        super.init()
    }


    struct Storage {
        static let models = db["detail_models"]
        static let id = Expression<Int>("id")
        static let modelId = Expression<Int>("model_id")

        static func createTable() {
            db.create(table: models) { t in
                t.column(self.id, primaryKey: true)
//                t.column(self.modelId, references: Model.Storage.id)  // depends on db setting
                t.column(self.modelId)
            }
        }
    }

    override func _insert() {
        if let insertedId = Storage.models.insert(
            Storage.modelId <- modelId) {
                debugPrintln(insertedId)
                id = insertedId
        }
    }

    override func _update() {
        if let result = Storage.models.filter(Storage.id == id).update(
            Storage.modelId <- modelId) {
                debugPrintln(result)
        }
    }

    override func _delete() -> Int? {
        let count = Storage.models.filter(Storage.id == id).delete()?
        debugPrintln("id: \(id), \(count) rows deleted")
        return count
    }
}


// MARK:- SQLite.swift extensions
extension Query {
    func map<T: ModelType>() -> [T] {
        var array = [T]()
        for row in self {
            array.append(T(row: row))
        }

        return array
    }

    // generic mapping function
    func map<T>(f: Row -> T) -> [T] {
        var array = [T]()
        for row in self {
            array.append(row.map(f))
        }

        return array
    }
}

extension Row {
    func map<T: ModelType>() -> T {
        return T(row: self)
    }

    // generic mapping function
    func map<T>(f: Row -> T) -> T {
        return f(self)
    }
}
