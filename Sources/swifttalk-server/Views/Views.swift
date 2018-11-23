//
//  Views.swift
//  Bits
//
//  Created by Chris Eidhof on 31.07.18.
//

import Foundation

struct RenderingError: LocalizedError {
    /// Private message for logging
    let privateMessage: String
    /// Message shown to the user
    let publicMessage: String

    var errorDescription: String? {
        return "RenderingError: \(privateMessage)"
    }
}

enum HeaderContent {
    case node(Node)
    case other(header: String, blurb: String?, extraClasses: Class)
    case link(header: String, backlink: Route, label: String)
    
    var asNode: [Node] {
        switch self {
        case let .node(n): return [n]
        case let .other(header: text, blurb: blurb, extraClasses: extraClasses): return
            [
                .h1(classes: "color-white bold" + extraClasses, [.text(text)]), // todo add pb class where blurb = nil
            ] + (blurb == nil ? [] : [
                .div(classes: "mt--", [
                .p(attributes: ["class": "ms2 color-darken-50 lh-110 mw7"], [Node.text(blurb!)])
                ])
        	])
        case let .link(header, backlink, label): return [
        	.link(to: backlink, attributes: ["class": "ms1 inline-block no-decoration lh-100 pb- color-white opacity-70 hover-underline"], [.text(label)]),
            .h1(attributes: ["class": "color-white bold ms4 pb"], [.text(header)])
        ]
        }
    }
}

func pageHeader(_ content: HeaderContent, extraClasses: Class? = nil) -> Node {
    return .header(classes: "bgcolor-blue pattern-shade" + (extraClasses ?? ""), [
        .div(classes: "container", content.asNode)
    ])
}

func errorView(_ message: String) -> Node {
    return LayoutConfig(context: Context(path: "", route: .error, session: nil), pageTitle: "Error", contents: [
        .div(classes: "container", [
            .text(message)
        ])
    ]).layoutForCheckout
}

