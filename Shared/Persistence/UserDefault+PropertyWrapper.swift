//
//  UserDefault+PropertyWrapper.swift
//  Remind (iOS)
//
//  Created by Titouan Van Belle on 10.01.21.
//

import Foundation

import Foundation

protocol UserDefaultConvertible {
    init?(with object: Any)
    func object() -> Any?
}

extension UserDefaultConvertible {
    init?(with object: Any) {
        guard let value = object as? Self else { return nil }
        self = value
    }
    func object() -> Any? { self }
}

extension String: UserDefaultConvertible {}
extension Int: UserDefaultConvertible {}
extension Bool: UserDefaultConvertible {}
extension Date: UserDefaultConvertible {}

extension UserDefaultConvertible where Self: Codable {
    init?(with object: Any) {
        guard let value = (object as? Data).flatMap({ try? JSONDecoder().decode(Self.self, from: $0) }) else { return nil }
        self = value
    }

    func object() -> Any? {
        try? JSONEncoder().encode(self)
    }
}

extension Optional: UserDefaultConvertible where Wrapped: UserDefaultConvertible {
    init?(with object: Any) {
        guard let value = Wrapped(with: object) else { return nil }
        self = .some(value)
    }

    func object() -> Any? {
        switch self {
        case .some(let value):
            return value.object()
        case .none:
            return nil
        }
    }
}

extension Array: UserDefaultConvertible where Element: UserDefaultConvertible {
    init?(with object: Any) {
        guard let value = (object as? [Any])?.compactMap(Element.init(with:)) else { return nil }
        self = value
    }

    func object() -> Any? {
        compactMap { $0.object() }
    }
}

struct UserDefaultTypedKey<T>: RawRepresentable, ExpressibleByStringLiteral {
    let rawValue: String
    init(rawValue v: String) { rawValue = v }
    init(stringLiteral v: String) { rawValue = v }

    static var allDayNotificationTime: UserDefaultTypedKey<Date> { "allDayNotificationTime" }
    static var needsOnboarding: UserDefaultTypedKey<Bool> { "needsOnboarding" }
}

@propertyWrapper
struct UserDefault<Value: UserDefaultConvertible> {
    let key: UserDefaultTypedKey<Value>
    let defaultValue: Value
    let defaults: UserDefaults

    init(_ key: UserDefaultTypedKey<Value>, defaultValue: Value, defaults: UserDefaults = .standard) {
        self.key = key
        self.defaultValue = defaultValue
        self.defaults = defaults
    }

    private static var defaults: UserDefaults { .standard }

    var wrappedValue: Value {
        get {
            defaults.object(forKey: key.rawValue).flatMap(Value.init(with:))
                ?? defaultValue
        }
        set {
            newValue.object().map { defaults.set($0, forKey: key.rawValue) }
                ?? defaults.removeObject(forKey: key.rawValue)
        }
    }
}
