//
//  LWWElementDictionary.swift
//  LWW-Element-Dictionary
//
//  Created by Žymantas Paulas on 2020-11-21.
//

import Foundation

public struct LWWElementDictionary<Key: Hashable, Value>: Equatable {
    private typealias ValueElement = (value: Value?, timestamp: TimeInterval)
    private typealias History = [Key: ValueElement]

    private var additionHistory = History()
    private var removalHistory = History()

    public init() { }

    // MARK: - Add Value

    public mutating func add(key: Key, value: Value, timestamp: TimeInterval) {
        self.assign(key: key, value: value, timestamp: timestamp, to: &self.additionHistory)
    }

    // MARK: - Update Value

    public mutating func update(key: Key, value: Value, timestamp: TimeInterval) {
        guard let element = self.additionHistory[key], timestamp >= element.timestamp else { return }
        self.additionHistory[key] = ValueElement(value: value, timestamp: timestamp)
    }

    // MARK: - Remove Value

    public mutating func remove(key: Key, timestamp: TimeInterval) {
        self.assign(key: key, timestamp: timestamp, to: &self.removalHistory)
    }

    // MARK: - Retrieve Value

    public func value(forKey key: Key) -> Value? {
        guard let addedElement = self.additionHistory[key] else { return nil }
        guard let removedElement = self.removalHistory[key] else { return addedElement.value }

        guard addedElement.timestamp >= removedElement.timestamp else { return nil }

        return addedElement.value
    }

    // MARK: - Merge Dictionaries

    public func merge(with dictionary: Self) -> Self {
        var newDictionary = Self.init()

        newDictionary.additionHistory = self.additionHistory.merging(dictionary.additionHistory) { value1, value2 -> ValueElement in
            return self.elementByComparing(leftElement: value1, rightElement: value2)
        }

        newDictionary.removalHistory = self.removalHistory.merging(dictionary.removalHistory) { value1, value2 -> ValueElement in
            return self.elementByComparing(leftElement: value1, rightElement: value2)
        }

        return newDictionary
    }

    // MARK: - Private

    private func elementByComparing(leftElement: ValueElement, rightElement: ValueElement) -> ValueElement {
        if leftElement.timestamp >= rightElement.timestamp { return leftElement }

        return rightElement
    }

    private func element(for key: Key, in history: History, and history2: History) -> ValueElement? {
        guard let leftElement = history[key], let rightElement = history2[key] else { return nil }

        return self.elementByComparing(leftElement: leftElement, rightElement: rightElement)
    }

    private func assign(key: Key, value: Value? = nil, timestamp: TimeInterval, to dictionary: inout [Key: ValueElement]) {
        let currentElement = dictionary[key]

        if currentElement != nil && currentElement!.timestamp > timestamp {
            return
        }

        dictionary[key] = ValueElement(value, timestamp)
    }

    public static func == (lhs: LWWElementDictionary<Key, Value>, rhs: LWWElementDictionary<Key, Value>) -> Bool {
        return (lhs.additionHistory.mapValues { $0.timestamp } == rhs.additionHistory.mapValues { $0.timestamp })
            && (lhs.removalHistory.mapValues { $0.timestamp } == rhs.removalHistory.mapValues { $0.timestamp })
    }
}
