//
//  Group+FetchRequests.swift
//  Yoda
//
//  Created by Titouan Van Belle on 19.01.21.
//

import CoreData

extension Group {

    // MARK: Fetch Requests

    private static var basicRequest: NSFetchRequest<Group> {
        let request = NSFetchRequest<Group>(entityName: "Group")
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        return request
    }

    static let all: NSFetchRequest<Group> = {
        basicRequest
    }()
}
