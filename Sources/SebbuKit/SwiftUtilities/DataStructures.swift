//
//  DataStructures.swift
//  
//
//  Created by Sebastian Toivonen on 31.1.2020.
//  Copyright © 2020 Sebastian Toivonen. All rights reserved.
//

public class Grid<T> {
    var matrix:[T]
    var rows:Int
    var columns:Int
    
    public init(rows:Int, columns:Int, defaultValue:T) {
        self.rows = rows
        self.columns = columns
        matrix = Array(repeating:defaultValue,count:(rows*columns))
    }
    
    internal func indexIsValidFor(row: Int, column: Int) -> Bool {
        return row >= 0 && row < rows && column >= 0 && column < columns
    }
    
    public subscript(col:Int, row:Int) -> T? {
        get{
            if indexIsValidFor(row: row, column: col) {
                return matrix[columns * row + col]
            } else {
                return nil
            }
        }
        set{
            if indexIsValidFor(row: row, column: col) {
                if let newValue = newValue {
                    matrix[columns * row + col] = newValue
                }
            }
        }
    }
}
