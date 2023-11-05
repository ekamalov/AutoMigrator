//
//  File.swift
//  
//
//  Created by laijihua on 2023/11/5.
//

import Foundation

public struct TableFieldConfig {
    let withoutForeignKey: Bool // 是否需要建立外键
    let sql: String? // 默认值
    
    init(withoutForeignKey: Bool = false, sql: String? = nil) {
        self.withoutForeignKey = withoutForeignKey
        self.sql = sql
    }
}
