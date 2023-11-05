//
//  File.swift
//
//
//  Created by Mats Mollestad on 31/10/2021.
//

import Foundation
import Fluent

public protocol AutomaticMigratable {
    var removeMigration: String { get }
    var fieldName: String { get }
    func getAddMigration(fieldConfig: TableFieldConfig?) -> String
}

extension AutomaticMigratable {
    public var removeMigration: String { ".deleteField(\"\(fieldName)\")" }
}

struct TableField: AutomaticMigratable {
    let name: String
    let dataType: DatabaseSchema.DataType
    let isRequired: Bool
    
    var fieldName: String { name }
        
    func getAddMigration(fieldConfig: TableFieldConfig?) -> String {
        var migration = ""
        migration += ".field(\"\(name)\", .\(dataType)"
        if isRequired {
            migration += ", .required)"
        } else {
            migration += ")"
        }
        return migration
    }
}
