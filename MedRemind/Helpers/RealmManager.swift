//
//  RealmManager.swift
//  MedRemind
//
//  Created by Pranjal Vyas on 02/03/22.
//

import Foundation

class RealmManager {
    
    // MARK:- functions
    static func realmConfig() -> Realm.Configuration {
        return Realm.Configuration(schemaVersion: 2, migrationBlock: { (migration, oldSchemaVersion) in
            /// Migration block. Useful when you upgrade the schema version.
            
        })
    }
    
    private static func realmInstance() -> Realm {
        do {
            let newRealm = try Realm(configuration: realmConfig())
            return newRealm
        } catch {
            print(error)
            fatalError("Unable to create an instance of Realm")
        }
    }
}
