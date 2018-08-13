//
//  RecurlyXMLDecoder.swift
//  Bits
//
//  Created by Chris Eidhof on 13.08.18.
//

import Foundation

struct DecodingError: Error {
    let message: String
}

extension XMLNode {
    fileprivate func contents() throws -> String? {
        guard let c = children else { return "" }
        var result: String = ""
        for child in c {
            guard child.kind == .text else { throw DecodingError(message: "Expected text, but got \(child)") }
            result += child.stringValue ?? ""
        }
        return result
    }
}

fileprivate final class RecurlyXMLDecoder: Decoder {
    var node: XMLNode
    var codingPath: [CodingKey] = []
    var userInfo: [CodingUserInfoKey : Any] = [:]
    init(_ element: XMLNode) {
        self.node = element
    }
    
    func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> where Key: CodingKey {
        return KeyedDecodingContainer(KDC(node))
    }
    
    struct KDC<Key: CodingKey>: KeyedDecodingContainerProtocol {
        let node: XMLNode
        init(_ node: XMLNode) {
            self.node = node
        }
        
        var codingPath: [CodingKey] = []
        
        var allKeys: [Key] {
            fatalError()
        }
        
        func contains(_ key: Key) -> Bool {
            return (node.children ?? []).contains { $0.name == key.stringValue }
        }
        
        func child(key: Key) -> XMLElement? {
            return node.children?.first { $0.name == key.stringValue }.flatMap { $0 as? XMLElement }
        }
        
        func requireChild(key: Key) throws -> XMLElement {
            let result = node.children?.first { $0.name == key.stringValue }.flatMap { $0 as? XMLElement }
            if let x = result {
                return x
            } else {
                throw DecodingError(message: "Expected node \"\(key.stringValue)\" but got none (context: \(node.xmlString))")
            }
        }
        
        func decodeNil(forKey key: Key) throws -> Bool {
            guard let c = child(key: key) else {
                return true
            }
            return c.attribute(forName: "nil") != nil
        }
        
        func decode(_ type: Bool.Type, forKey key: Key) throws -> Bool {
            guard let c = try requireChild(key: key).contents() else {
                throw DecodingError(message: "Expected a string for key: \(key)")
            }
            switch c {
            case "true": return true
            case "false": return false
            default: throw DecodingError(message: "Expected a bool but got \(c)")
            }
        }
        
        func decode(_ type: String.Type, forKey key: Key) throws -> String {
            guard let c = try requireChild(key: key).contents() else {
                throw DecodingError(message: "Expected a string for key: \(key) context: \(node)")
            }
            return c
        }
        
        func decode(_ type: Double.Type, forKey key: Key) throws -> Double {
            guard let c = try child(key: key)?.contents(), let d = Double(c) else {
                throw DecodingError(message: "Expected a string for key: \(key)")
            }
            return d
            
        }
        
        func decode(_ type: Float.Type, forKey key: Key) throws -> Float {
            guard let c = try child(key: key)?.contents(), let d = Float(c) else {
                throw DecodingError(message: "Expected a string for key: \(key)")
            }
            return d
        }
        
        func decode(_ type: Int.Type, forKey key: Key) throws -> Int {
            guard let c = try child(key: key)?.contents(), let i = Int(c) else {
                throw DecodingError(message: "Expected a string for key: \(key)")
            }
            return i
        }
        
        func decode(_ type: Int8.Type, forKey key: Key) throws -> Int8 {
            fatalError()
        }
        
        func decode(_ type: Int16.Type, forKey key: Key) throws -> Int16 {
            fatalError()
        }
        
        func decode(_ type: Int32.Type, forKey key: Key) throws -> Int32 {
            fatalError()
        }
        
        func decode(_ type: Int64.Type, forKey key: Key) throws -> Int64 {
            fatalError()
        }
        
        func decode(_ type: UInt.Type, forKey key: Key) throws -> UInt {
            fatalError()
        }
        
        func decode(_ type: UInt8.Type, forKey key: Key) throws -> UInt8 {
            fatalError()
        }
        
        func decode(_ type: UInt16.Type, forKey key: Key) throws -> UInt16 {
            fatalError()
        }
        
        func decode(_ type: UInt32.Type, forKey key: Key) throws -> UInt32 {
            fatalError()
        }
        
        func decode(_ type: UInt64.Type, forKey key: Key) throws -> UInt64 {
            fatalError()
        }
        
        func decode<T>(_ type: T.Type, forKey key: Key) throws -> T where T : Decodable {
            let node = try requireChild(key: key)
            if type == URL.self {
                guard let value = node.attribute(forName: "href")?.stringValue else {
                    throw DecodingError(message: "Expected a \"href\" attribute")
                }
                guard let u = URL(string: value) else {
                    throw DecodingError(message: "Malformed URL in node: \(node.xmlString)")
                }
                return u as! T
            } else if type == Date.self {
                guard let c = try node.contents() else { throw DecodingError(message: "Expected a date, got nothing") }
                guard let d = DateFormatter.iso8601WithTimeZone.date(from: c) else { throw DecodingError(message: "Malformatted date: \(c)") }
                return d as! T
            }
            let decoder = RecurlyXMLDecoder(node)
            return try T(from: decoder)
        }
        
        func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type, forKey key: Key) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
            fatalError()
        }
        
        func nestedUnkeyedContainer(forKey key: Key) throws -> UnkeyedDecodingContainer {
            fatalError()
        }
        
        func superDecoder() throws -> Decoder {
            fatalError()
        }
        
        func superDecoder(forKey key: Key) throws -> Decoder {
            fatalError()
        }
    }
    
    struct UDC: UnkeyedDecodingContainer {
        let nodes: [XMLNode]
        var codingPath: [CodingKey]
        var count: Int? { return nodes.count }
        var isAtEnd: Bool { return currentIndex >= nodes.count }
        var currentIndex: Int
        
        mutating func err<T: Decodable>() throws -> T {
            throw DecodingError(message: "Can't decode")
        }
        mutating func decodeNil() throws -> Bool {
            return try err()
        }
        
        mutating func decode(_ type: Bool.Type) throws -> Bool {
            return try err()
        }
        
        mutating func decode(_ type: String.Type) throws -> String {
            return try err()
        }
        
        mutating func decode(_ type: Double.Type) throws -> Double {
            return try err()
        }
        
        mutating func decode(_ type: Float.Type) throws -> Float {
            return try err()
        }
        
        mutating func decode(_ type: Int.Type) throws -> Int {
            return try err()
        }
        
        mutating func decode(_ type: Int8.Type) throws -> Int8 {
            return try err()
        }
        
        mutating func decode(_ type: Int16.Type) throws -> Int16 {
            return try err()
        }
        
        mutating func decode(_ type: Int32.Type) throws -> Int32 {
            return try err()
        }
        
        mutating func decode(_ type: Int64.Type) throws -> Int64 {
            return try err()
        }
        
        mutating func decode(_ type: UInt.Type) throws -> UInt {
            return try err()
        }
        
        mutating func decode(_ type: UInt8.Type) throws -> UInt8 {
            return try err()
        }
        
        mutating func decode(_ type: UInt16.Type) throws -> UInt16 {
            return try err()
        }
        
        mutating func decode(_ type: UInt32.Type) throws -> UInt32 {
            return try err()
        }
        
        mutating func decode(_ type: UInt64.Type) throws -> UInt64 {
            return try err()
        }
        
        mutating func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
            let str = String(describing: type).lowercased()
            let node = nodes[currentIndex]
            guard node.name == str else {
                throw DecodingError(message: "Expected a node named \(str), but got: \(nodes[currentIndex])")
            }
            currentIndex += 1
            var x = RecurlyXMLDecoder(node)
            return try T(from: x)
        }
        
        mutating func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
            fatalError()
        }
        
        mutating func nestedUnkeyedContainer() throws -> UnkeyedDecodingContainer {
            fatalError()
        }
        
        mutating func superDecoder() throws -> Decoder {
            fatalError()
        }
        
    }
    
    func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        return UDC(nodes: node.children ?? [], codingPath: [], currentIndex: 0)
    }
    
    func singleValueContainer() throws -> SingleValueDecodingContainer {
        return SVDC(node)
    }
    
    struct SVDC: SingleValueDecodingContainer {
        let node: XMLNode
        
        var codingPath: [CodingKey] = []
        
        func decodeNil() -> Bool {
            if node.name != nil {
                return false
            }
            return true
//            fatalError("Node: \(node)")
        }
        
        func decode(_ type: Bool.Type) throws -> Bool {
            fatalError()
        }
        
        func decode(_ type: String.Type) throws -> String {
            guard let c = try node.contents() else {
                throw DecodingError(message: "Expected a string in \(node)")
            }
            return c
        }
        
        func decode(_ type: Double.Type) throws -> Double {
            fatalError()
        }
        
        func decode(_ type: Float.Type) throws -> Float {
            fatalError()
        }
        
        func decode(_ type: Int.Type) throws -> Int {
            fatalError()
        }
        
        func decode(_ type: Int8.Type) throws -> Int8 {
            fatalError()
        }
        
        func decode(_ type: Int16.Type) throws -> Int16 {
            fatalError()
        }
        
        func decode(_ type: Int32.Type) throws -> Int32 {
            fatalError()
        }
        
        func decode(_ type: Int64.Type) throws -> Int64 {
            fatalError()
        }
        
        func decode(_ type: UInt.Type) throws -> UInt {
            fatalError()
        }
        
        func decode(_ type: UInt8.Type) throws -> UInt8 {
            fatalError()
        }
        
        func decode(_ type: UInt16.Type) throws -> UInt16 {
            fatalError()
        }
        
        func decode(_ type: UInt32.Type) throws -> UInt32 {
            fatalError()
        }
        
        func decode(_ type: UInt64.Type) throws -> UInt64 {
            fatalError()
        }
        
        func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
            return try T.init(from: RecurlyXMLDecoder(node))
        }
        
        init(_ node: XMLNode) {
            self.node = node
        }
    }
}

// Decodes the children of the document's root element
func decodeXML<T: Decodable>(from data: Data) throws -> T {
    guard let x: XMLElement = try XMLDocument(data: data, options: []).rootElement() else {
        throw DecodingError(message: "Couldn't parse XML")
    }
    let decoder = RecurlyXMLDecoder(x)
    return try T(from: decoder)
}

