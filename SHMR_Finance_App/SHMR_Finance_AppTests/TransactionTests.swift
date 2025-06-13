//
//  TransactionTests.swift
//  SHMR_Finance_AppTests
//
//  Created by Chernokoz on 14.06.2025.
//

import XCTest

@testable import SHMR_Finance_App

class TransactionTests: XCTestCase {
    
    private let dateFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()
    
    private lazy var transaction = Transaction(
        id: 124,
        accountId: 124,
        categoryId: 33,
        amount: Decimal(111.11),
        transactionDate: dateFormatter.date(from: "2025-06-13T18:32:45.686Z")!,
        comment: "Чаевые",
        createdAt: dateFormatter.date(from: "2025-06-13T18:32:45.686Z")!,
        updatedAt: dateFormatter.date(from: "2025-06-13T18:32:45.686Z")!
    )

    private lazy var json: [String: Any] = [
        "id": 124,
        "accountId": 124,
        "categoryId": 33,
        "amount": "111.11",
        "transactionDate": "2025-06-13T18:32:45.686Z",
        "comment": "Чаевые",
        "createdAt": "2025-06-13T18:32:45.686Z",
        "updatedAt": "2025-06-13T18:32:45.686Z"
    ]

    //тесты для сериализации (jsonObject)

    func testTransactionToJsonObject() {
        
        let jsonObject = transaction.jsonObject

        guard let jsonDict = jsonObject as? [String: Any] else {
            XCTFail("Failed to convert to dictionary")
            return
        }
        
        XCTAssertEqual(jsonDict["id"] as? Int, transaction.id)
        XCTAssertEqual(jsonDict["accountId"] as? Int, transaction.accountId)
        XCTAssertEqual(jsonDict["categoryId"] as? Int, transaction.categoryId)
        XCTAssertEqual(jsonDict["amount"] as? String, transaction.amount.description)
        XCTAssertEqual(jsonDict["transactionDate"] as? String, dateFormatter.string(from: transaction.transactionDate))
        XCTAssertEqual(jsonDict["createdAt"] as? String, dateFormatter.string(from: transaction.createdAt))
        XCTAssertEqual(jsonDict["updatedAt"] as? String, dateFormatter.string(from: transaction.updatedAt))
        XCTAssertEqual(jsonDict["comment"] as? String, transaction.comment)
    }

    func testJsonObjectWithEmptyComment() {
        let transaction = Transaction(
            id: 2,
            accountId: 3,
            categoryId: 4,
            amount: Decimal(100),
            transactionDate: Date(),
            comment: "",
            createdAt: Date(),
            updatedAt: Date()
        )

        let jsonObject = transaction.jsonObject
        let parsedTransaction = Transaction.parse(jsonObject: jsonObject)

        XCTAssertNotNil(parsedTransaction)
        XCTAssertEqual(parsedTransaction?.comment, "")
    }

    //тесты для десериализации (static func parse(jsonObject:))

    func testParseJsonObjectRoundTrip() {
        let parsed = Transaction.parse(jsonObject: json)!
        
        XCTAssertEqual(parsed.id, transaction.id)
        XCTAssertEqual(parsed.accountId, transaction.accountId)
        XCTAssertEqual(parsed.categoryId, transaction.categoryId)
        XCTAssertEqual(parsed.amount, transaction.amount)
        XCTAssertEqual(parsed.transactionDate, transaction.transactionDate)
        XCTAssertEqual(parsed.comment, transaction.comment)
        XCTAssertEqual(parsed.createdAt, transaction.createdAt)
        XCTAssertEqual(parsed.updatedAt, transaction.updatedAt)
    }

    func testParseJsonObjectInvalidAmount() {
        var tempJson = json
        tempJson["amount"] = "not_a_number"
        
        let transaction = Transaction.parse(jsonObject: tempJson)
        XCTAssertNil(transaction)
    }

    func testParseJsonObjectInvalidDate() {
        var tempJson = json
        tempJson["transactionDate"] = "not_a_date"
        
        let transaction = Transaction.parse(jsonObject: tempJson)
        XCTAssertNil(transaction)
    }

    func testParseJsonObjectMissingId() {
        var tempJson = json
        tempJson.removeValue(forKey: "id")
        
        let transaction = Transaction.parse(jsonObject: tempJson)
        XCTAssertNil(transaction)
    }

    func testParseJsonObjectMissingAmount() {
        var tempJson = json
        tempJson.removeValue(forKey: "amount")
        
        let transaction = Transaction.parse(jsonObject: tempJson)
        XCTAssertNil(transaction)
    }

    func testParseJsonObjectNullComment() {
        var tempJson = json
        tempJson["comment"] = NSNull()
        
        let parsed = Transaction.parse(jsonObject: tempJson)!
        XCTAssertNil(parsed.comment)
    }

    func testParseJsonObjectMissingCommentField() {
        var tempJson = json
        tempJson.removeValue(forKey: "comment")
        
        let parsed = Transaction.parse(jsonObject: tempJson)!
        XCTAssertNil(parsed.comment)
    }
}

