//
//  HTML.swift
//  Bits
//
//  Created by Chris Eidhof on 31.07.18.
//

import Foundation

import Foundation

enum Node {
    case node(El)
    case text(String)
    case raw(String)
}

struct El {
    var name: String
    var attributes: [String:String]
    var block: Bool
    var children: [Node]
    
    init(name: String, block: Bool = true, attributes: [String:String] = [:], children: [Node] = []) {
        self.name = name
        self.attributes = attributes
        self.children = children
        self.block = block
    }
}

extension Dictionary where Key == String, Value == String {
    var asAttributes: String {
        return isEmpty ? "" : " " + map { (k,v) in
            "\(k)=\"\(v)\"" // todo escape
            }.joined(separator: " ")

    }
}

extension El {
    var render: String {
        let atts: String = attributes.asAttributes
        if children.isEmpty && !block {
            return "<\(name)\(atts) />"
        } else if block {
            return "<\(name)\(atts)>\n" + children.map { $0.render }.joined(separator: "\n") + "\n</\(name)>"
        } else {
            return "<\(name)\(atts)>" + children.map { $0.render }.joined(separator: "") + "</\(name)>"
        }
    }
}
extension Node {
    var render: String {
        switch self {
        case .text(let s): return s // todo escape
        case .raw(let s): return s
        case .node(let n): return n.render
        }
    }
    
    var document: String {
        return ["<!DOCTYPE html>", render].joined(separator: "\n")
    }
}

extension Node {
    static func html(attributes: [String:String] = [:], _ children: [Node] = []) -> Node {
        return .node(El(name: "html", attributes: attributes, children: children))
    }
    
    static func meta(attributes: [String:String] = [:]) -> Node {
        return .node(El(name: "meta", block: false, attributes: attributes, children: []))
    }
    
    static func body(attributes: [String:String] = [:], _ children: [Node] = []) -> Node {
        return .node(El(name: "body", attributes: attributes, children: children))
    }
    
    static func p(attributes: [String:String] = [:], _ children: [Node]) -> Node {
        return .node(El(name: "p", attributes: attributes, children: children))
    }
    
    static func head(attributes: [String:String] = [:], _ children: [Node] = []) -> Node {
        return .node(El(name: "head", attributes: attributes, children: children))
    }
    
    static func header(attributes: [String:String] = [:], _ children: [Node] = []) -> Node {
        return .node(El(name: "header", attributes: attributes, children: children))
    }
    
    static func title(_ text: String) -> Node {
        return .node(El(name: "title", block: false, children: [.text(text)]))
    }

    static func span(attributes: [String:String] = [:], _ text: [Node]) -> Node {
        return .node(El(name: "span", block: false, attributes: attributes, children: text))
    }

    static func h1(_ title: [Node], attributes: [String:String] = [:]) -> Node {
        return .node(El(name: "h1", block: false, attributes: attributes, children: title))
    }
    
    static func h2(_ title: [Node], attributes: [String:String] = [:]) -> Node {
        return .node(El(name: "h2", block: false, attributes: attributes, children: title))
    }
    
    static func h3(_ title: [Node], attributes: [String:String] = [:]) -> Node {
        return .node(El(name: "h3", block: false, attributes: attributes, children: title))
    }
    
    static func img(src: String, alt: String = "", attributes: [String:String] = [:]) -> Node {
        var a = attributes
        a["src"] = src
        a["alt"] = alt
        return .node(El(name: "img", block: false, attributes: a, children: []))
    }

    static func div(attributes: [String:String] = [:], _ children: [Node] = []) -> Node {
        return .node(El(name: "div", attributes: attributes, children: children))
    }
    
    static func aside(attributes: [String:String] = [:], _ children: [Node] = []) -> Node {
        return .node(El(name: "div", attributes: attributes, children: children))
    }
    
    static func div(class c: String, _ children: [Node] = []) -> Node {
        let attributes = ["class": c]
        return .node(El(name: "div", attributes: attributes, children: children))
    }
    
    static func video(attributes: [String:String] = [:], _ source: URL, sourceType: String) -> Node {
        return .node(El(name: "video", attributes: attributes, children: [
            .node(El(name: "source", attributes: [
                "src": source.absoluteString,
                "type": sourceType
            ]))
        ]))
    }
    
    static func nav(attributes: [String:String] = [:], _ children: [Node] = []) -> Node {
        return .node(El(name: "nav", attributes: attributes, children: children))
    }
    
    static func ul(attributes: [String:String] = [:], _ children: [Node] = []) -> Node {
        return .node(El(name: "ul", attributes: attributes, children: children))
    }
    
    static func ol(attributes: [String:String] = [:], _ children: [Node] = []) -> Node {
        return .node(El(name: "ol", attributes: attributes, children: children))
    }
    
    static func li(attributes: [String:String] = [:], _ children: [Node] = []) -> Node {
        return .node(El(name: "li", attributes: attributes, children: children))
    }
    
    static func button(attributes: [String:String] = [:], _ children: [Node] = []) -> Node {
        return .node(El(name: "button", attributes: attributes, children: children))
    }
    
    static func main(attributes: [String:String] = [:], _ children: [Node] = []) -> Node {
        return .node(El(name: "main", attributes: attributes, children: children))
    }
    
    static func section(attributes: [String:String] = [:], _ children: [Node] = []) -> Node {
        return .node(El(name: "section", attributes: attributes, children: children))
    }
    
    static func article(attributes: [String:String] = [:], _ children: [Node] = []) -> Node {
        return .node(El(name: "article", attributes: attributes, children: children))
    }
    
    static func figure(attributes: [String:String] = [:], _ children: [Node] = []) -> Node {
        return .node(El(name: "figure", attributes: attributes, children: children))
    }    
    
    static func stylesheet(media: String = "all", href: String) -> Node {
        let attributes = [
            "rel": "stylesheet",
            "href": href,
            "media": media
        ]
        return .node(El(name: "link", attributes: attributes, children: []))
    }
    
    static func a(attributes: [String:String] = [:], _ title: [Node], href: String) -> Node {
        assert(attributes["href"] == nil)
        var att = attributes
        att["href"] = href
        return .node(El(name: "a", block: false, attributes: att, children: title))
    }
}

extension Node: ExpressibleByStringLiteral {
    init(stringLiteral: String) {
        self = .text(stringLiteral)
    }
}
