//
//  Photo+CoreDataProperties.swift
//  
//
//  Created by Aleksey Razzhivaykin on 06.07.16.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Photo {

    @NSManaged var photoID: String?
    @NSManaged var farm: NSNumber?
    @NSManaged var server: String?
    @NSManaged var secret: String?
    @NSManaged var latitude: NSNumber?
    @NSManaged var longitude: NSNumber?
    @NSManaged var thumbnail: NSData?

}
