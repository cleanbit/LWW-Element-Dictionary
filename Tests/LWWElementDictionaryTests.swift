//
//  LWWElementDictionaryTests.swift
//  LWWElementDictionaryTests
//
//  Created by Žymantas Paulas on 2020-11-21.
//

import LWWElementDictionary
import XCTest

class LWWElementDictionaryTests: XCTestCase {
    func testUpdateNothing() {
        var dictionary = LWWElementDictionary<String, String>()

        dictionary.update(key: "key", value: "value", timestamp: 10)

        XCTAssertNil(dictionary.value(forKey: "key"))
    }

    func testMergeWithSelf() {
        var dictionary = LWWElementDictionary<String, String>()

        let key = "1"
        let key2 = "1"

        dictionary.add(key: key, value: "10", timestamp: 10)
        dictionary.remove(key: key2, timestamp: 10)

        let newDictionary = dictionary.merge(with: dictionary)

        XCTAssertEqual(dictionary, newDictionary)
    }

    func testMerge() {
        var dictionary1 = LWWElementDictionary<String, String>()
        var dictionary2 = LWWElementDictionary<String, String>()

        let key = "1"
        let key2 = "2"
        let key3 = "3"

        dictionary1.add(key: key, value: "10", timestamp: 10)
        dictionary1.add(key: key, value: "5", timestamp: 10)

        dictionary1.add(key: key3, value: "100", timestamp: 100)
        dictionary1.remove(key: key3, timestamp: 50)

        dictionary2.add(key: key, value: "50", timestamp: 50)
        dictionary2.add(key: key2, value: "20", timestamp: 10)

        dictionary2.add(key: key3, value: "10", timestamp: 10)
        dictionary2.remove(key: key3, timestamp: 200)

        let newDictionary = dictionary1.merge(with: dictionary2)

        XCTAssertEqual(newDictionary.value(forKey: key), "50")
        XCTAssertEqual(newDictionary.value(forKey: key2), "20")

        XCTAssertNil(newDictionary.value(forKey: key3))

        let newDictionary2 = dictionary2.merge(with: dictionary1)

        XCTAssertEqual(newDictionary, newDictionary2)
    }

    func testAdditionsAndRemovalsWithIdenticalTimestamp() {
        var dictionary = LWWElementDictionary<String, String>()

        let key = "1"
        let key2 = "2"

        dictionary.add(key: key, value: "10", timestamp: 10)
        dictionary.add(key: key, value: "5", timestamp: 10)

        dictionary.add(key: key2, value: "20", timestamp: 10)
        dictionary.remove(key: key2, timestamp: 10)

        XCTAssertEqual(dictionary.value(forKey: key), "5")
        XCTAssertNotEqual(dictionary.value(forKey: key), "10")

        XCTAssertEqual(dictionary.value(forKey: key2), "20")
    }

    func testUpdateWithOlderTimestamp() {
        var dictionary = LWWElementDictionary<String, String>()

        let key = "1"

        dictionary.add(key: key, value: "10", timestamp: 10)
        dictionary.add(key: key, value: "5", timestamp: 5)

        dictionary.update(key: key, value: "20", timestamp: 1)

        XCTAssertNotEqual(dictionary.value(forKey: key), "20")
        XCTAssertEqual(dictionary.value(forKey: key), "10")
    }

    func testSucessfulAddition() {
        var dictionary = LWWElementDictionary<String, String>()

        let key = "1"

        dictionary.add(key: key, value: "10", timestamp: 10)
        dictionary.add(key: key, value: "5", timestamp: 5)

        dictionary.add(key: key, value: "20", timestamp: 20)

        XCTAssertEqual(dictionary.value(forKey: key), "20")
    }

    func testSucessfulUpdate() {
        var dictionary = LWWElementDictionary<String, String>()

        let key = "1"

        dictionary.add(key: key, value: "10", timestamp: 10)
        dictionary.add(key: key, value: "5", timestamp: 5)

        dictionary.update(key: key, value: "20", timestamp: 20)

        XCTAssertEqual(dictionary.value(forKey: key), "20")
    }

    func testSuccesfulRemoval() {
        var dictionary = LWWElementDictionary<String, String>()

        let key = "1"

        dictionary.add(key: key, value: "10", timestamp: 10)
        dictionary.add(key: key, value: "5", timestamp: 5)

        dictionary.remove(key: key, timestamp: 20)

        XCTAssertNil(dictionary.value(forKey: key))
    }

    func testTwoNonEqualDictionaries() {
        var dictionary1 = LWWElementDictionary<String, String>()
        var dictionary2 = LWWElementDictionary<String, String>()

        let key = "1"

        dictionary1.add(key: key, value: "10", timestamp: 100)
        dictionary1.add(key: key, value: "5", timestamp: 5)
        dictionary1.add(key: key, value: "1", timestamp: 1)

        dictionary2.add(key: key, value: "1", timestamp: 1)
        dictionary2.add(key: key, value: "5", timestamp: 5)
        dictionary2.add(key: key, value: "10", timestamp: 10)

        let key2 = "1"

        dictionary1.remove(key: key2, timestamp: 10)
        dictionary1.remove(key: key2, timestamp: 1)
        dictionary1.remove(key: key2, timestamp: 100)

        dictionary2.remove(key: key2, timestamp: 10)
        dictionary2.remove(key: key2, timestamp: 1)
        dictionary2.remove(key: key2, timestamp: 20)

        XCTAssertNotEqual(dictionary1, dictionary2)
    }

    func testTwoEqualDictionaries() {
        var dictionary1 = LWWElementDictionary<String, String>()
        var dictionary2 = LWWElementDictionary<String, String>()

        let key = "1"

        dictionary1.add(key: key, value: "10", timestamp: 10)
        dictionary1.add(key: key, value: "5", timestamp: 5)
        dictionary1.add(key: key, value: "1", timestamp: 1)

        dictionary2.add(key: key, value: "1", timestamp: 1)
        dictionary2.add(key: key, value: "5", timestamp: 5)
        dictionary2.add(key: key, value: "10", timestamp: 10)

        let key2 = "1"

        dictionary1.remove(key: key2, timestamp: 10)
        dictionary1.remove(key: key2, timestamp: 1)
        dictionary1.remove(key: key2, timestamp: 20)

        dictionary2.remove(key: key2, timestamp: 10)
        dictionary2.remove(key: key2, timestamp: 1)
        dictionary2.remove(key: key2, timestamp: 20)

        XCTAssertEqual(dictionary1, dictionary2)
    }

    func testOutOfOrderTimestamps() {
        var dictionary = LWWElementDictionary<String, String>()

        let key = "1"
        let key2 = "2"

        dictionary.add(key: key, value: "5", timestamp: 5)
        dictionary.add(key: key, value: "10", timestamp: 10)
        dictionary.add(key: key, value: "1", timestamp: 1)

        dictionary.add(key: key2, value: "1", timestamp: 10)
        dictionary.remove(key: key2, timestamp: 300)
        dictionary.add(key: key2, value: "1", timestamp: 1)

        XCTAssertEqual(dictionary.value(forKey: key), "10")
        XCTAssertNil(dictionary.value(forKey: key2))
    }

    func testConvergence() {
        var dictionary1 = LWWElementDictionary<String, String>()
        var dictionary2 = LWWElementDictionary<String, String>()
        
        let key = "1"

        dictionary1.add(key: key, value: "foo", timestamp: 1)
        dictionary1.remove(key: key, timestamp: 1)

        dictionary2.remove(key: key, timestamp: 1)
        dictionary2.add(key: key, value: "foo", timestamp: 1)

        XCTAssertEqual(dictionary1.value(forKey: key), dictionary2.value(forKey: key))
    }
}
