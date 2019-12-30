//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import XCTest
import FeedStoreChallenge

class FeedStoreChallengeTests: XCTestCase, FeedStoreSpecs {
    
    override func setUp() {
        super.setUp()
        
        setupEmptyStoreState()
    }
    
    override func tearDown() {
        undoStoreState()
        
        super.tearDown()
    }

	func test_retrieve_deliversEmptyOnEmptyCache() {
		let sut = makeSUT()

		assertThatRetrieveDeliversEmptyOnEmptyCache(on: sut)
	}

	func test_retrieve_hasNoSideEffectsOnEmptyCache() {
		let sut = makeSUT()

		assertThatRetrieveHasNoSideEffectsOnEmptyCache(on: sut)
	}

	func test_retrieve_deliversFoundValuesOnNonEmptyCache() {
		let sut = makeSUT()

		assertThatRetrieveDeliversFoundValuesOnNonEmptyCache(on: sut)
	}

	func test_retrieve_hasNoSideEffectsOnNonEmptyCache() {
		let sut = makeSUT()

		assertThatRetrieveHasNoSideEffectsOnNonEmptyCache(on: sut)
	}

	func test_insert_deliversNoErrorOnEmptyCache() {
		let sut = makeSUT()

		assertThatInsertDeliversNoErrorOnEmptyCache(on: sut)
	}

	func test_insert_deliversNoErrorOnNonEmptyCache() {
		let sut = makeSUT()

		assertThatInsertDeliversNoErrorOnNonEmptyCache(on: sut)
	}

	func test_insert_overridesPreviouslyInsertedCacheValues() {
		let sut = makeSUT()

		assertThatInsertOverridesPreviouslyInsertedCacheValues(on: sut)
	}

	func test_delete_deliversNoErrorOnEmptyCache() {
		let sut = makeSUT()

		assertThatDeleteDeliversNoErrorOnEmptyCache(on: sut)
	}

	func test_delete_hasNoSideEffectsOnEmptyCache() {
		let sut = makeSUT()

		assertThatDeleteHasNoSideEffectsOnEmptyCache(on: sut)
	}

	func test_delete_deliversNoErrorOnNonEmptyCache() {
		let sut = makeSUT()

		assertThatDeleteDeliversNoErrorOnNonEmptyCache(on: sut)
	}

	func test_delete_emptiesPreviouslyInsertedCache() {
		let sut = makeSUT()

		assertThatDeleteEmptiesPreviouslyInsertedCache(on: sut)
	}

	func test_storeSideEffects_runSerially() {
		let sut = makeSUT()

		assertThatSideEffectsRunSerially(on: sut)
	}
	
	// MARK: - Helpers
	
    private func makeSUT(storeURL: URL? = nil, file: StaticString = #file, line: UInt = #line) -> FeedStore {
        let url = storeURL ?? testSpecificStoreURL()
        let sut = CodableFeedStore(storeURL: url)
        trackMemoryLeaksFor(sut, file: file, line: line)
		return sut
	}
    
    private func trackMemoryLeaksFor(_ instance: AnyObject, file: StaticString = #file, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should have been deallocated. Potenteial memory leak.", file: file, line: line)
        }
    }
    
    private func testSpecificStoreURL() -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("\(type(of: self)).store")
    }
    
    private func deleteStoreArtifacts() {
        try? FileManager.default.removeItem(at: testSpecificStoreURL())
    }
    
    private func setupEmptyStoreState() {
        deleteStoreArtifacts()
    }
    
    private func undoStoreState() {
        deleteStoreArtifacts()
    }
}

extension FeedStoreChallengeTests: FailableRetrieveFeedStoreSpecs {
    
    func test_retrieve_deliversFailureOnRetrievalError() {
        let storeURL = testSpecificStoreURL()
        let sut = makeSUT(storeURL: storeURL)
        
        writeInvalidData(to: storeURL)

        assertThatRetrieveDeliversFailureOnRetrievalError(on: sut)
    }

    func test_retrieve_hasNoSideEffectsOnFailure() {
        let storeURL = testSpecificStoreURL()
        let sut = makeSUT(storeURL: storeURL)
        
        writeInvalidData(to: storeURL)

        assertThatRetrieveHasNoSideEffectsOnFailure(on: sut)
    }
    
    // MARK: - FeedStoreChallengeTests Helpers
    
    private func writeInvalidData(to storeURL: URL) {
        try! "invalid data".write(to: storeURL, atomically: false, encoding: .utf8)
    }
}

extension FeedStoreChallengeTests: FailableInsertFeedStoreSpecs {
    
    func test_insert_deliversErrorOnInsertionError() {
        let invalidURL = invalidStoreURL()
        let sut = makeSUT(storeURL: invalidURL)

        assertThatInsertDeliversErrorOnInsertionError(on: sut)
    }

    func test_insert_hasNoSideEffectsOnInsertionError() {
        let invalidURL = invalidStoreURL()
        let sut = makeSUT(storeURL: invalidURL)

        assertThatInsertHasNoSideEffectsOnInsertionError(on: sut)
    }

    // MARK: - FeedStoreChallengeTests Helpers
    
    private func invalidStoreURL() -> URL {
        return URL(string: "invalid://store-url")!
    }
}

extension FeedStoreChallengeTests: FailableDeleteFeedStoreSpecs {
    
    func test_delete_deliversErrorOnDeletionError() {
        let noDeletionPermissionURL = cachesDirectoryURL()
        let sut = makeSUT(storeURL: noDeletionPermissionURL)

        assertThatDeleteDeliversErrorOnDeletionError(on: sut)
    }

    func test_delete_hasNoSideEffectsOnDeletionError() {
        let noDeletionPermissionURL = cachesDirectoryURL()
        let sut = makeSUT(storeURL: noDeletionPermissionURL)

        assertThatDeleteHasNoSideEffectsOnDeletionError(on: sut)
    }
    
    // MARK: - FeedStoreChallengeTests Helpers
    
    private func cachesDirectoryURL() -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
}
