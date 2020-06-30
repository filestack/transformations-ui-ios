//
//  LinkedList.swift
//  TransformationsUI
//
//  Created by Ruben Nine on 29/10/2019.
//  Copyright © 2019 Filestack. All rights reserved.
//

import Foundation

struct LinkedList<Element> {
    fileprivate var head: Node?
    private var tail: Node?

    var isEmpty: Bool { head == nil }
    var first: Node? { head }
    var last: Node? { tail }

    @discardableResult mutating func append(value: Element) -> Node {
        let newNode = Node(value: value)

        if let tailNode = tail {
            newNode.previous = tailNode
            tailNode.next = newNode
        } else {
            head = newNode
        }

        tail = newNode

        return newNode
    }

    @discardableResult mutating func remove(node: Node) -> Element {
        let prev = node.previous
        let next = node.next

        if let prev = prev {
            prev.next = next
        } else {
            head = next
        }

        next?.previous = prev

        if next == nil {
            tail = prev
        }

        node.previous = nil
        node.next = nil

        return node.value
    }

    mutating func removeAll() {
        head = nil
        tail = nil
    }
}

// MARK: - LinkedList Node

extension LinkedList {
    class Node {
        var value: Element
        var next: Node?
        weak var previous: Node?

        init(value: Element) {
            self.value = value
        }
    }
}

// MARK: - Sequence Conformance

extension LinkedList: Sequence {
    typealias Element = Node

    __consuming func makeIterator() -> Iterator {
        return Iterator(node: head)
    }

    struct Iterator: IteratorProtocol {
        private var currentNode: Node?

        fileprivate init(node: Node?) {
            currentNode = node
        }

        mutating func next() -> Node? {
            guard let node = currentNode else { return nil }

            currentNode = node.next

            return node
        }
    }
}
