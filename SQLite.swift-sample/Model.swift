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
    init()
    init(row: Row)
}

protocol RecordType {
    func save()
    func delete(#cascade: Bool) -> Int?
    func delete() -> Int?
}


class Association<T: ModelType> : SequenceType {
    let uuid = NSUUID()
    typealias Generator = IndexingGenerator<[T]>
    lazy var array: [T] = self.reload()

    var query: SQLite.Query
    var count: Int { return array.count }

    init(query: SQLite.Query) {
        self.query = query
    }

    func reload() -> [T] {
        debugPrintln("reloading association \(uuid)")
        array = query.map() as [T]
        return array
    }

    func generate() -> Generator {
        return array.generate()
    }

    subscript(index: Int) -> T {
        get {
            return array[index]
        }
        set {
            array[index] = newValue
        }
    }

    func append(newElement: T) {
        array.append(newElement)

    }

    func extend(newElements: [T]) {
        array.extend(newElements)
    }
}


class Model: ModelType, RecordType {
    typealias T = Model
    var dirty = false

    var id = 0
    var name: String
    var unique: String = ""
    var optional: String?
    lazy var details: Association<DetailModel> = {
        return Association<DetailModel>(query: DetailModel.Storage.models.filter(DetailModel.Storage.modelId == self.id))
    }()

    required convenience init() {
        self.init(name: "")
    }

    init(name: String) {
        self.name = name
    }

    required init(row: Row) {
        self.id = row[Storage.id]
        self.name = row[Storage.name]
        self.unique = row[Storage.unique]
        self.optional = row[Storage.optional]
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

        static func dropTable() {
            db.drop(table: models, ifExists: true)
        }
    }

    func save() {
        if id > 0 {
            update()
        } else {
            insert()
        }

        cascadingUpdate()
    }

    func update() {
        if let result = Storage.models.filter(Storage.id == id).update(
            Storage.name <- name,
            Storage.unique <- unique,
            Storage.optional <- optional) {
                debugPrintln(result)
        }
    }

    func insert() {
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

    func cascadingUpdate() {
//        if let details = _details {
            for detail in details {
                detail.modelId = id
                detail.save()
            }
//        }
    }


    func delete() -> Int? {
        return delete(cascade: true)
    }

    func delete(#cascade: Bool) -> Int? {
        if cascade {
            cascadingDelete()
        }

        let count = Storage.models.filter(Storage.id == id).delete()?
        debugPrintln("id: \(id), \(count) rows deleted")
        return count
    }

    func cascadingDelete() -> Int? {
        if let count = DetailModel.Storage.models.filter(DetailModel.Storage.modelId == id).delete()? {
            debugPrintln("id: \(id), \(count) nested rows deleted")
            return count
        }

        return nil
    }
}


class DetailModel: ModelType, RecordType {
    typealias T = DetailModel

    var id = 0
    var modelId = 0


    required init() {}

    required init(row: Row) {
        self.id = row[Storage.id]
        self.modelId = row[Storage.modelId]
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

        static func dropTable() {
            db.drop(table: models, ifExists: true)
        }
    }

    func save() {
        if id > 0 {
            update()
        } else {
            insert()
        }
    }

    func insert() {
        if let insertedId = Storage.models.insert(
            Storage.modelId <- modelId) {
                debugPrintln(insertedId)
                id = insertedId
        }
    }

    func update() {
        if let result = Storage.models.filter(Storage.id == id).update(
            Storage.modelId <- modelId) {
                debugPrintln(result)
        }
    }

    func delete() -> Int? {
        return delete(cascade: true)
    }

    func delete(#cascade: Bool) -> Int? {
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
