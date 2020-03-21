//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import XCTest
import FeedStoreChallenge

class FeedStoreChallengeTests: XCTestCase, FeedStoreSpecs {
    
    private lazy var feedStoreURL = URL(fileURLWithPath: "dev/null")
    
    override func tearDown() {
        try? FileManager.default.removeItem(at: feedStoreURL)
        
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
	
    private func makeSUT(url: URL? = nil, file: StaticString = #file, line: UInt = #line) -> FeedStore {
        let storeURL = url ?? feedStoreURL
        let feedStoreBundle = Bundle(for: CoreDataFeedStore.self)
        let sut = try! CoreDataFeedStore(url: storeURL, bundle: feedStoreBundle)
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
}

extension FeedStoreChallengeTests: FailableRetrieveFeedStoreSpecs {

	func test_retrieve_deliversFailureOnRetrievalError() {
        let url = feedStoreURL
        let sut = makeSUT(url: url)
        
        try! "invalid data".write(to: url, atomically: false, encoding: .utf8)

		assertThatRetrieveDeliversFailureOnRetrievalError(on: sut)
	}

	func test_retrieve_hasNoSideEffectsOnFailure() {
		let url = feedStoreURL
        let sut = makeSUT(url: url)
        
        try! "invalid data".write(to: url, atomically: false, encoding: .utf8)

		assertThatRetrieveHasNoSideEffectsOnFailure(on: sut)
	}
}

extension FeedStoreChallengeTests: FailableInsertFeedStoreSpecs {

	func test_insert_deliversErrorOnInsertionError() {
        let sut = FeedStoreStub(failure: [.insert])

		assertThatInsertDeliversErrorOnInsertionError(on: sut)
	}

	func test_insert_hasNoSideEffectsOnInsertionError() {
        let sut = FeedStoreStub(failure: [.insert])

		assertThatInsertHasNoSideEffectsOnInsertionError(on: sut)
	}

}

extension FeedStoreChallengeTests: FailableDeleteFeedStoreSpecs {

	func test_delete_deliversErrorOnDeletionError() {
        let sut = FeedStoreStub(failure: [.delete])

		assertThatDeleteDeliversErrorOnDeletionError(on: sut)
	}

	func test_delete_hasNoSideEffectsOnDeletionError() {
		let sut = FeedStoreStub(failure: [.delete])

		assertThatDeleteHasNoSideEffectsOnDeletionError(on: sut)
	}

}

private final class FeedStoreStub: FeedStore {
    enum Error: Swift.Error {
        case couldNotDelete
        case couldNotInsert
        case couldNotRetrieve
    }
    
    struct Failure: OptionSet {
        let rawValue: Int
        
        static let delete = Failure(rawValue: 1 << 0)
        static let insert = Failure(rawValue: 1 << 1)
        static let retrieve = Failure(rawValue: 1 << 2)
        
        init(rawValue: Int = 0) {
            self.rawValue = rawValue
        }
    }
    
    let failure: Failure
    
    init(failure: Failure = []) {
        self.failure = failure
    }
    
    func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        if failure.contains(.delete) {
            completion(Error.couldNotDelete)
        } else {
            completion(nil)
        }
    }
    
    func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        if failure.contains(.insert) {
            completion(Error.couldNotInsert)
        } else {
            completion(nil)
        }
    }
    
    func retrieve(completion: @escaping RetrievalCompletion) {
        if failure.contains(.retrieve) {
            completion(.failure(Error.couldNotRetrieve))
        } else {
            completion(.empty)
        }
    }
}
