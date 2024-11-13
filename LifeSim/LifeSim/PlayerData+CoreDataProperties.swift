//
//  PlayerData+CoreDataProperties.swift
//  LifeSim
//
//  Created by Sadie Argueta on 11/12/24.
//
//

import Foundation
import CoreData


extension PlayerData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PlayerData> {
        return NSFetchRequest<PlayerData>(entityName: "PlayerData")
    }

    @NSManaged public var gameData: String?
    @NSManaged public var playerAge: Int64
    @NSManaged public var playerName: String?
    @NSManaged public var saveDate: Date?

}

extension PlayerData : Identifiable {

}
