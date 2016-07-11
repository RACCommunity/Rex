public protocol BindingsProtocol {
    associatedtype Owner: AnyObject

    var owner: Owner { get }
}

public protocol BindablesProviding: class {}
extension BindablesProviding {
    public var bindables: Bindables<Self> {
        return Bindables(owner: self)
    }
}

public struct Bindables<Owner: AnyObject>: BindingsProtocol {
    public let owner: Owner
}
