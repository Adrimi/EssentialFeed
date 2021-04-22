//
//  ManagedFeedImage.swift
//  EssentialFeed
//
//  Created by adrian.szymanowski on 14/12/2020.
//

import CoreData

@objc(ManagedFeedImage)
internal class ManagedFeedImage: NSManagedObject {
    @NSManaged internal var id: UUID
    @NSManaged internal var imageDescription: String?
    @NSManaged internal var location: String?
    @NSManaged internal var url: URL
    @NSManaged internal var data: Data?
    @NSManaged internal var cache: ManagedCache
}

extension ManagedFeedImage {
    static func data(with url: URL, in context: NSManagedObjectContext) throws -> Data? {
        if let data = context.userInfo[url] as? Data { return data }
        
        return try first(with: url, in: context)?.data
    }
    
    internal static func first(with url: URL, in context: NSManagedObjectContext) throws -> ManagedFeedImage? {
         let request = NSFetchRequest<ManagedFeedImage>(entityName: entity().name!)
         request.predicate = NSPredicate(format: "%K = %@", argumentArray: [#keyPath(ManagedFeedImage.url), url])
         request.returnsObjectsAsFaults = false
         request.fetchLimit = 1
         return try context.fetch(request).first
     }
    
    internal static func images(from localFeed: [LocalFeedImage], in context: NSManagedObjectContext) -> NSOrderedSet {
        let images = NSOrderedSet(array: localFeed.map { local in
            let managed = ManagedFeedImage(context: context)
            managed.id = local.id
            managed.imageDescription = local.description
            managed.location = local.location
            managed.url = local.url
            managed.data = context.userInfo[local.url] as? Data
            return managed
        })
        context.userInfo.removeAllObjects()
        return images
    }

    internal var local: LocalFeedImage {
        return LocalFeedImage(id: id, description: imageDescription, location: location, url: url)
    }
    
    override func prepareForDeletion() {
        super.prepareForDeletion()
        
        managedObjectContext?.userInfo[url] = data
    }
}
