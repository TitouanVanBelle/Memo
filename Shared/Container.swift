//
//  Container.swift
//  Yoda (iOS)
//
//  Created by Titouan Van Belle on 20.01.21.
//

import Coil
import Foundation

final class Container: Resolver {

    static var `default` = Container()

    let `internal`: Coil.Container

    init() {
        `internal` = Coil.Container()
            .register(Dependency { _ in CoreDatabase() as CoreDatabaseProtocol })
            .register(Dependency { _ in SoundsPlayer() as SoundsPlayerProtocol })
            .register(Dependency { _ in Notifier() as NotifierProtocol })
    }

    func resolve<Service>(_ type: Service.Type) -> Service? {
        `internal`.resolve(type)
    }
}
