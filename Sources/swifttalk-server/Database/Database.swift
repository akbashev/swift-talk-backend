//
//  Database.swift
//  Bits
//
//  Created by Chris Eidhof on 08.08.18.
//

import Foundation
import PostgreSQL

struct DatabaseError: Error, LocalizedError {
    let err: Error
    let query: String

    public var errorDescription: String? {
        return "\(err), query: \(query)"
    }
}


let postgresConfig = env.databaseURL.map { url in ConnInfo.raw(url) } ?? ConnInfo.params([
    "host": env.databaseHost,
    "dbname": env.databaseName,
    "user": env.databaseUser,
    "password": env.databasePassword,
    "connect_timeout": "1",
])

let postgreSQL = try! PostgreSQL.Database(connInfo: postgresConfig)

func withConnection<A>(_ x: (Connection) throws -> A) throws -> A {
    let conn = try postgreSQL.makeConnection()
    let result = try x(conn)
    try conn.close()
    return result
}

func lazyConnection() -> Lazy<Connection> {
    return Lazy<Connection>({ () throws -> Connection in
        return try postgreSQL.makeConnection()
    }, cleanup: { conn in
        try? conn.close()
    })
}

protocol Insertable: Codable {
    static var tableName: String { get }
}

extension Encodable {
    var fields: (names: [String], values: [NodeRepresentable]) {
        let m = Mirror(reflecting: self)
        let children = Array(m.children)
        let names = children.map { $0.label!.snakeCased }
        let values = children.map { $0.value as! NodeRepresentable }
        return (names, values)
    }
}

extension Sequence where Element == String {
    var sqlJoined: String {
        return joined(separator: ",")
    }
}

extension Decodable {    
    static var fieldNames: [String] {
        return try! PropertyNamesDecoder.decode(Self.self).map { $0.snakeCased }
    }
}

extension CSRFToken: NodeRepresentable {
    func makeNode(in context: PostgreSQL.Context?) throws -> PostgreSQL.Node {
        return value.makeNode(in: context)
    }
}


extension Connection {
    @discardableResult
    func execute<A>(_ query: Query<A>, loggingTreshold: TimeInterval = 0.1) throws -> A {
//        print(query.query)
        let node = try measure(message: "query: \(query.query)", treshold: loggingTreshold) { () throws -> PostgreSQL.Node in
            do {
                return try execute(query.query, query.values)
            } catch {
                throw DatabaseError(err: error, query: query.query)
            }
        }
        return query.parse(node)
    }
}


