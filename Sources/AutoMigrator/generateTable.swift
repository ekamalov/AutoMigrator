//
//  File.swift
//  
//
//  Created by Mats Mollestad on 01/11/2021.
//

import Foundation
import Fluent

public struct Table {
    public let name: String
    public let fields: [AutomaticMigratable]
    public let config: [String: TableFieldConfig] // 对某些field的独特配置
}

public func generateTable<T: Model>(_ model: T.Type, config: [String: TableFieldConfig] = [:]) -> Table {
    
    var fields = [AutomaticMigratable]()
    
    for property in T.init().properties {
        if let migratable = property as? AutomaticMigratable {
            fields.append(migratable)
        }
    }
    
    return Table(name: model.schema, fields: fields, config: config)
}

extension AutoMigrator {

    func migration(old: [AutomaticMigratable], new: [AutomaticMigratable], table: Table? = nil) -> (String, String) {
        let newLine = "\n            "
        var upgradeMigration = ""
        var downgradeMigration = ""
        
        var oldState = old.reduce(into: [:]) { partialResult, field in
            partialResult[field.fieldName] = field
        }
        
        for field in new {
            if oldState[field.fieldName] == nil {
                upgradeMigration += newLine + field.getAddMigration(fieldConfig: table?.config[field.fieldName])
                downgradeMigration += newLine + field.removeMigration
            } else {
                oldState[field.fieldName] = nil
            }
        }
        
        for removedField in oldState.values {
            downgradeMigration += newLine + removedField.getAddMigration(fieldConfig: table?.config[removedField.fieldName])
            upgradeMigration += newLine + removedField.removeMigration
        }
        
        return (upgradeMigration, downgradeMigration)
    }
}
