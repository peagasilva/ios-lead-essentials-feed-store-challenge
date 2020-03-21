//
//  CoreDataFeedStore.swift
//  FeedStoreChallenge
//
//  Created by Raphael Silva on 21/03/2020.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import Foundation
import CoreData

public final class CoreDataFeedStore: FeedStore {
    
    private let persistentContainer: NSPersistentContainer
    private let context: NSManagedObjectContext

    public init(url: URL, bundle: Bundle = .main) throws {
        persistentContainer = try NSPersistentContainer.load(modelName: "CoreDataFeedStore", url: url, in: bundle)
        context = persistentContainer.newBackgroundContext()
    }
    
    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {}
    
    public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        
    }
    
    public func retrieve(completion: @escaping RetrievalCompletion) {
        completion(.empty)
    }
}

// MARK: - NSPersistentContainer Extension

extension NSPersistentContainer {
    enum LoadError: Swift.Error {
        case didNotFindModel
        case didFailToLoadPersistentStores(Swift.Error)
    }
    
    static func load(modelName name: String, url: URL, in bundle: Bundle) throws -> NSPersistentContainer {
        guard let model = NSManagedObjectModel.with(name: name, in: bundle) else {
            throw LoadError.didNotFindModel
        }
        
        var loadError: Swift.Error?
        
        let persistentStoreDescription = NSPersistentStoreDescription(url: url)
        let persistentContainer = NSPersistentContainer(name: name, managedObjectModel: model)
        persistentContainer.persistentStoreDescriptions = [persistentStoreDescription]
        persistentContainer.loadPersistentStores { (_, error) in
            loadError = error
        }
        
        try loadError.map { throw LoadError.didFailToLoadPersistentStores($0) }
        
        return persistentContainer
    }
}

// MARK: - NSManagedObjectModel

extension NSManagedObjectModel {
    static func with(name: String, in bundle: Bundle) -> NSManagedObjectModel? {
        return bundle.url(forResource: name, withExtension: "momd").flatMap { NSManagedObjectModel(contentsOf: $0) }
    }
}

// MARK: - Core Data Models

@objc(ManagedCache)
private class ManagedCache: NSManagedObject {
    @NSManaged public var timestamp: Date
    @NSManaged public var feed: NSOrderedSet
}

@objc(ManagedFeedImage)
private class ManagedFeedImage: NSManagedObject {
    @NSManaged var id: UUID
    @NSManaged var imageDescription: String?
    @NSManaged var location: String?
    @NSManaged var url: URL
    @NSManaged var cache: ManagedCache
}
