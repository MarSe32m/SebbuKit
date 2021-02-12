//
//  Memoization.swift
//  
//
//  Created by Sebastian Toivonen on 26.1.2021.
//

/// Usage
/*
    func fibonacci(_ number: Int) -> Int {...}
    
    let memoizedFibonacci = memoize(fibonacci)
    
    let k = memoizedFibonacci(2)

 */
public func memoize<Input: Hashable, Output>(_ function: @escaping (Input) -> Output) -> (Input) -> Output {
    var storage = [Input: Output]()
    
    return { input in
        if let cached = storage[input] {
            return cached
        }
        
        let result = function(input)
        storage[input] = result
        return result
    }
}

/// Usage
/*
     let recursiveMemoizedFibonacci = recursiveMemoize { fibonacci, number in
         number < 2 ? number : fibonacci(number - 1) + fibonacci(number - 2)
     }
     let k = recursiveMemoizedFibonacci(55)
 */
public func recursiveMemoize<Input: Hashable, Output>(_ function: @escaping ((Input) -> Output, Input) -> Output) -> (Input) -> Output {
    var storage = [Input: Output]()
    var memo: ((Input) -> Output)!
    
    memo = { input in
        if let cached = storage[input] {
            return cached
        }
        
        let result = function(memo, input)
        storage[input] = result
        return result
    }
    
    return memo
}

public let memoizedFibonacci: (Int) -> Int = recursiveMemoize { fibonacci, number in
    number < 2 ? number : fibonacci(number - 1) + fibonacci(number - 2)
}

public let memoizedCollatz: (Int) -> Int = recursiveMemoize { collatz, number in
    if number == 1 { return 1 }
    if number & 1 == 0 {
        return collatz(number / 2) + 1
    } else {
        return collatz(number * 3 + 1) + 1
    }
}
