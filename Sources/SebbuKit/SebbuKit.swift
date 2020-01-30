public struct SebbunStruct {
    public private(set) var modified: Bool
    
    public init() {
        modified = true
    }
}

public func someFunction() -> Int {
    print("Hello gello")
    return 42
}
