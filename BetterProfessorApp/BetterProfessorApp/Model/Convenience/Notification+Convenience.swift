//
//  Notification+Convenience.swift
//  BetterProfessorApp
//
//  Created by Cody Morley on 4/28/20.
//  Copyright © 2020 Lambda. All rights reserved.
//

import Foundation
import CoreData

extension Notification {
    // MARK: - Extended Properties
    /// Use dot syntax to call a codable representation of a model object
    var notificationRepresentation: NotificationRepresentation? {
        guard let message = message,
            let notifyTime = notifyTime else { return nil }
        return NotificationRepresentation(id: id,
                                          message: message,
                                          notifyTime: notifyTime,
                                          deadlineID: deadlineID)
    }
    // MARK: - Initializers
    /// Use these convenience initializers to move Model objects between CoreData and the network API
    @discardableResult convenience init(id: Int64,
                                        message: String,
                                        notifyTime: Date,
                                        deadlineID: Int64,
                                        context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        self.init(context: context)
        self.id = id
        self.message = message
        self.notifyTime = notifyTime
        self.deadlineID = deadlineID
    }
    @discardableResult convenience init?(representation: NotificationRepresentation,
                                         context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        self.init(context: context)
        self.id = representation.id
        self.message = representation.message
        self.notifyTime = representation.notifyTime
        self.deadlineID = representation.deadlineID
    }
}
