//
//  RequestEnvironment.swift
//  Bits
//
//  Created by Chris Eidhof on 14.12.18.
//

import Foundation
import PostgreSQL

struct RequestEnvironment {
    var hashedAssetName: (String) -> String = { $0 }
    private let _session: Lazy<Session?>
    let route: Route
    private let _connection: Lazy<Connection>
    init(route: Route, hashedAssetName: @escaping (String) -> String, buildSession: @escaping () -> Session?, connection: Lazy<Connection>) {
        self.hashedAssetName = hashedAssetName
        self._session = Lazy(buildSession, cleanup: { _ in () })
        self.route = route
        self._connection = connection
    }
    
    var session: Session? { return flatten(try? _session.get()) }
    
    var context: Context {
        return Context(route: route, message: nil, session: session)
    }
    
    func connection() throws -> Connection {
        return try _connection.get()
    }
}