//
//  File.swift
//
//
//  Created by Mats Mollestad on 01/11/2021.
//

import Foundation
import Fluent

func dataType<T>(from type: T.Type) -> DatabaseSchema.DataType {
    let reflection = String(describing: T.self)
    
    if reflection.starts(with: "Array") {
        guard let firstIndex = reflection.range(of: "<")?.upperBound,
              let lastIndex = reflection.range(of: ">")?.lowerBound else {
            fatalError("Unsupported Array Datatype")
        }
        let type = String(reflection[firstIndex..<lastIndex])
        return .array(of: dataType(from: type))
    } else {
        return dataType(from: reflection)
    }
}

private func dataType(from type: String) -> DatabaseSchema.DataType {
    switch type {
    case "String": return .string
    case "UUID": return .uuid
    case "Double": return .double
    case "Int": return .int
    case "Date": return .datetime
    case "Bool": return .bool
    default: fatalError("Unsupported Datatype")
    }
}

extension FieldProperty: AutomaticMigratable {
    public var fieldName: String { key.description }
    
    public func getAddMigration(fieldConfig: TableFieldConfig?) -> String {
        if let fieldConfig = fieldConfig {
            if let sql = fieldConfig.sql {
                return ".field(\"\(fieldName)\", .\(dataType(from: Value.self)), .required, .sql(\(sql)))"
            }
        }
        return ".field(\"\(fieldName)\", .\(dataType(from: Value.self)), .required)"
    }
}

extension OptionalFieldProperty: AutomaticMigratable {
    public var fieldName: String { key.description }
    
    public func getAddMigration(fieldConfig: TableFieldConfig?) -> String {
        if let fieldConfig = fieldConfig {
            if let sql = fieldConfig.sql {
                return ".field(\"\(fieldName)\", .\(dataType(from: WrappedValue.self)), .sql(\(sql)))"
            }
        }
        return ".field(\"\(fieldName)\", .\(dataType(from: WrappedValue.self)))"
    }
}

extension IDProperty: AutomaticMigratable {
    public var fieldName: String { key.description }
    
    public func getAddMigration(fieldConfig: TableFieldConfig?) -> String {
        if let fieldConfig = fieldConfig {
            if let sql = fieldConfig.sql {
                return ".field(\"\(fieldName)\", .\(dataType(from: Value.self)), .identifier(auto: false), .sql(\(sql)))"
            }
        }
        return ".field(\"\(fieldName)\", .\(dataType(from: Value.self)), .identifier(auto: false))"
    }
}

extension TimestampProperty: AutomaticMigratable {
    public var fieldName: String { $timestamp.key.description }
    
    public func getAddMigration(fieldConfig: TableFieldConfig?) -> String {
        if let fieldConfig = fieldConfig {
            if let sql = fieldConfig.sql {
                return ".field(\"\(fieldName)\", .datetime, .sql(\(sql)))"
            }
        }
        return ".field(\"\(fieldName)\", .datetime)"
    }
}

extension ParentProperty: AutomaticMigratable {
    public var fieldName: String { $id.key.description }
    
    public func getAddMigration(fieldConfig: TableFieldConfig?) -> String {
        
        if let fieldConfig = fieldConfig {
            var ret: String
            
            if fieldConfig.withoutForeignKey {
                ret = ".field(\"\(fieldName)\", .\(dataType(from: To.IDValue.self)), .required"
            } else {
                ret = ".field(\"\(fieldName)\", .\(dataType(from: To.IDValue.self)), .required, .references(\"\(To.schema)\", .id, onDelete: .cascade, onUpdate: .cascade)"
            }
            
            if let sql = fieldConfig.sql {
                return "\(ret), .sql(\(sql)))"
            } else {
                return "\(ret))"
            }
        }
        
        return ".field(\"\(fieldName)\", .\(dataType(from: To.IDValue.self)), .required, .references(\"\(To.schema)\", .id, onDelete: .cascade, onUpdate: .cascade))"
    }
}

extension OptionalParentProperty: AutomaticMigratable {
    public var fieldName: String { $id.key.description }
    
    public func getAddMigration(fieldConfig: TableFieldConfig?) -> String {
        
        if let fieldConfig = fieldConfig {
            var ret: String
            
            if fieldConfig.withoutForeignKey {
                ret = ".field(\"\(fieldName)\", .\(dataType(from: To.IDValue.self))"
            } else {
                ret = ".field(\"\(fieldName)\", .\(dataType(from: To.IDValue.self)), .references(\"\(To.schema)\", .id, onDelete: .cascade, onUpdate: .cascade)"
            }
            
            if let sql = fieldConfig.sql {
                return "\(ret), .sql(\(sql)))"
            } else {
                return "\(ret))"
            }
        }
        
        return ".field(\"\(fieldName)\", .\(dataType(from: To.IDValue.self)), .references(\"\(To.schema)\", .id, onDelete: .cascade, onUpdate: .cascade))"
    }
}
