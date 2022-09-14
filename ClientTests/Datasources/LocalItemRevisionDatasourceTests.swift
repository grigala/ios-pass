//
// LocalItemRevisionDatasourceTests.swift
// Proton Pass - Created on 14/08/2022.
// Copyright (c) 2022 Proton Technologies AG
//
// This file is part of Proton Pass.
//
// Proton Pass is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// Proton Pass is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with Proton Pass. If not, see https://www.gnu.org/licenses/.

@testable import Client
import XCTest

final class LocalItemRevisionDatasourceTests: XCTestCase {
    let expectationTimeOut: TimeInterval = 3
    var sut: LocalItemRevisionDatasource!

    override func setUp() {
        super.setUp()
        sut = .init(container: .Builder.build(name: kProtonPassContainerName,
                                              inMemory: true))
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func assertEqual(_ lhs: ItemRevision, _ rhs: ItemRevision) {
        XCTAssertEqual(lhs.itemID, rhs.itemID)
//        XCTAssertEqual(lhs.revision, rhs.revision)
//        XCTAssertEqual(lhs.contentFormatVersion, rhs.contentFormatVersion)
        XCTAssertEqual(lhs.rotationID, rhs.rotationID)
        XCTAssertEqual(lhs.content, rhs.content)
        XCTAssertEqual(lhs.userSignature, rhs.userSignature)
        XCTAssertEqual(lhs.itemKeySignature, rhs.itemKeySignature)
        XCTAssertEqual(lhs.state, rhs.state)
        XCTAssertEqual(lhs.signatureEmail, rhs.signatureEmail)
        XCTAssertEqual(lhs.aliasEmail, rhs.aliasEmail)
        XCTAssertEqual(lhs.createTime, rhs.createTime)
        XCTAssertEqual(lhs.modifyTime, rhs.modifyTime)
    }
}

extension LocalItemRevisionDatasourceTests {
    func testGetItemRevision() throws {
        continueAfterFailure = false
        let expectation = expectation(description: #function)
        Task {
            // Given
            let givenShareId = String.random()
            let givenItemId = String.random()
            let givenInsertItemRevision =
            try await sut.givenInsertedItemRevision(itemId: givenItemId,
                                                    shareId: givenShareId)

            // When
            for _ in 0...10 {
                try await sut.upsertItemRevisions([.random()], shareId: .random())
            }

            // Then
            let itemRevision = try await sut.getItemRevision(shareId: givenShareId,
                                                             itemId: givenItemId)
            XCTAssertNotNil(itemRevision)
            let nonNilItemRevision = try XCTUnwrap(itemRevision)
            assertEqual(nonNilItemRevision, givenInsertItemRevision)
            expectation.fulfill()
        }
        waitForExpectations(timeout: expectationTimeOut)
    }

//    func testGetItemRevisions() throws {
//        continueAfterFailure = false
//        let expectation = expectation(description: #function)
//        Task {
//            // Given
//            let localShareDatasource = LocalShareDatasource(container: sut.container)
//            let givenShare = try await localShareDatasource.givenInsertedShare(userId: nil)
//            let shareId = givenShare.shareID
//            let givenItemRevisions = [ItemRevision].random(count: 310,
//                                                           randomElement: .random())
//
//            // When
//            try await sut.upsertItemRevisions(givenItemRevisions, shareId: shareId)
//
//            // Then
//            let itemRevisionCount = try await sut.getItemRevisionCount(shareId: shareId)
//            XCTAssertEqual(itemRevisionCount, givenItemRevisions.count)
//            let itemRevisionIds = Set(itemRevisions.map { $0.itemID })
//            let givenItemRevisionIds = Set(givenItemRevisions.map { $0.itemID })
//            XCTAssertEqual(itemRevisionIds, givenItemRevisionIds)
//
//            expectation.fulfill()
//        }
//        waitForExpectations(timeout: expectationTimeOut)
//    }

    func testInsertItemRevisions() throws {
        continueAfterFailure = false
        let expectation = expectation(description: #function)
        Task {
            // Given
            let firstItemRevisions = [ItemRevision].random(randomElement: .random())
            let secondItemRevisions = [ItemRevision].random(randomElement: .random())
            let thirdItemRevisions = [ItemRevision].random(randomElement: .random())
            let givenItemsRevisions = firstItemRevisions + secondItemRevisions + thirdItemRevisions
            let givenShareId = String.random()

            // When
            try await sut.upsertItemRevisions(firstItemRevisions, shareId: givenShareId)
            try await sut.upsertItemRevisions(secondItemRevisions, shareId: givenShareId)
            try await sut.upsertItemRevisions(thirdItemRevisions, shareId: givenShareId)

            // Then
            let itemRevisionCount = try await sut.getItemRevisionCount(shareId: givenShareId)
            XCTAssertEqual(itemRevisionCount, givenItemsRevisions.count)

            let activeItemRevisions = try await sut.getItemRevisions(shareId: givenShareId,
                                                                     state: .active)
            let activeItemRevisionIds = activeItemRevisions.map { $0.itemID }

            let trashedItemRevisions = try await sut.getItemRevisions(shareId: givenShareId,
                                                                      state: .trashed)
            let trashedItemRevisionIds = trashedItemRevisions.map { $0.itemID }

            let givenItemRevisionIds = Set(givenItemsRevisions.map { $0.itemID })

            XCTAssertEqual(Set(activeItemRevisionIds + trashedItemRevisionIds),
                           givenItemRevisionIds)

            expectation.fulfill()
        }
        waitForExpectations(timeout: expectationTimeOut)
    }

    func testUpdateItemRevisions() throws {
        continueAfterFailure = false
        let expectation = expectation(description: #function)
        Task {
            // Given
            let givenItemId = String.random()
            let givenShareId = String.random()
            let insertedItemRevision =
            try await sut.givenInsertedItemRevision(itemId: givenItemId,
                                                    shareId: givenShareId)
            let updatedItemRevison = ItemRevision.random(itemId: insertedItemRevision.itemID)

            // When
            try await sut.upsertItemRevisions([updatedItemRevison], shareId: givenShareId)

            // Then
            let itemRevisionCount = try await sut.getItemRevisionCount(shareId: givenShareId)
            XCTAssertEqual(itemRevisionCount, 1)

            let itemRevision = try await sut.getItemRevision(shareId: givenShareId,
                                                             itemId: givenItemId)
            let notNilItemRevision = try XCTUnwrap(itemRevision)
            assertEqual(notNilItemRevision, updatedItemRevison)

            expectation.fulfill()
        }
        waitForExpectations(timeout: expectationTimeOut)
    }

    func testTrashItemRevisions() throws {
        continueAfterFailure = false
        let expectation = expectation(description: #function)
        Task {
            // Given
            let givenItemId = String.random()
            let givenShareId = String.random()
            let insertedItemRevision =
            try await sut.givenInsertedItemRevision(itemId: givenItemId,
                                                    shareId: givenShareId,
                                                    state: .active)

            // When
            try await sut.trashItemRevisions([insertedItemRevision], shareId: givenShareId)

            // Then
            let itemRevision = try await sut.getItemRevision(shareId: givenShareId,
                                                             itemId: givenItemId)
            let notNilItemRevision = try XCTUnwrap(itemRevision)
            XCTAssertEqual(notNilItemRevision.revisionState, .trashed)

            expectation.fulfill()
        }
        waitForExpectations(timeout: expectationTimeOut)
    }

    func testDeleteItemRevisions() throws {
        continueAfterFailure = false
        let expectation = expectation(description: #function)
        Task {
            // Given
            let shareId = String.random()
            let firstItem = try await sut.givenInsertedItemRevision(shareId: shareId)
            let secondItem = try await sut.givenInsertedItemRevision(shareId: shareId)
            let thirdItem = try await sut.givenInsertedItemRevision(shareId: shareId)

            let firstCount = try await sut.getItemRevisionCount(shareId: shareId)
            XCTAssertEqual(firstCount, 3)

            // Delete third item
            try await sut.deleteItemRevisions([thirdItem], shareId: shareId)
            let secondCount = try await sut.getItemRevisionCount(shareId: shareId)
            XCTAssertEqual(secondCount, 2)

            // Delete both first and second item
            try await sut.deleteItemRevisions([firstItem, secondItem], shareId: shareId)
            let thirdCount = try await sut.getItemRevisionCount(shareId: shareId)
            XCTAssertEqual(thirdCount, 0)

            expectation.fulfill()
        }
        waitForExpectations(timeout: expectationTimeOut)
    }

    func testRemoveAllRevisions() throws {
        continueAfterFailure = false
        let expectation = expectation(description: #function)
        Task {
            // Given
            let givenFirstShareId = String.random()
            let givenFirstShareItemRevisions =
            [ItemRevision].random(randomElement: .random())

            let givenSecondShareId = String.random()
            let givenSecondShareItemRevisions =
            [ItemRevision].random(randomElement: .random())

            // When
            try await sut.upsertItemRevisions(givenFirstShareItemRevisions,
                                              shareId: givenFirstShareId)
            try await sut.upsertItemRevisions(givenSecondShareItemRevisions,
                                              shareId: givenSecondShareId)

            // Then
            let firstShareItemRevisionsFirstGetCount =
            try await sut.getItemRevisionCount(shareId: givenFirstShareId)
            XCTAssertEqual(firstShareItemRevisionsFirstGetCount,
                           givenFirstShareItemRevisions.count)

            let secondShareItemRevisionsFirstGetCount =
            try await sut.getItemRevisionCount(shareId: givenSecondShareId)
            XCTAssertEqual(secondShareItemRevisionsFirstGetCount,
                           givenSecondShareItemRevisions.count)

            // When
            try await sut.removeAllItemRevisions(shareId: givenFirstShareId)

            // Then
            let firstShareItemRevisionsSecondGetCount =
            try await sut.getItemRevisionCount(shareId: givenFirstShareId)
            XCTAssertEqual(firstShareItemRevisionsSecondGetCount, 0)

            let secondShareItemRevisionsSecondGetCount =
            try await sut.getItemRevisionCount(shareId: givenSecondShareId)
            XCTAssertEqual(secondShareItemRevisionsSecondGetCount,
                           givenSecondShareItemRevisions.count)

            expectation.fulfill()
        }
        waitForExpectations(timeout: expectationTimeOut)
    }
}

extension LocalItemRevisionDatasource {
    func givenInsertedItemRevision(itemId: String? = nil,
                                   shareId: String? = nil,
                                   state: ItemRevisionState? = nil) async throws -> ItemRevision {
        let itemRevision = ItemRevision.random(itemId: itemId ?? .random(), state: state)
        try await upsertItemRevisions([itemRevision], shareId: shareId ?? .random())
        return itemRevision
    }
}
