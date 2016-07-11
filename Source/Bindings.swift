public protocol BindingsProtocol {
    associatedtype Owner: AnyObject

    var owner: Owner { get }
}

public protocol BindingsProviding: class {}
extension BindingsProviding {
    public var rex: Bindings<Self> {
        return Bindings(owner: self)
    }
}

public struct Bindings<Owner: AnyObject>: BindingsProtocol {
    public let owner: Owner
}
