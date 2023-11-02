import Vapor

/// Represents a module in the app.
///
/// A module is a self-contained entity within the Zenix app and represents a piece of functionality.
/// Every module is responsible for defining and handling its own routes withing the `boot(_ app: Application)` function.
public protocol ModuleInterface {
    
    static var identifier: String { get }
    
    /// Provides all routes handled by this module. This is used to bootstrap the app's routes so leaving this function empty means the module will not have any endpoints.
    func boot(_ app: Application) throws
    
    /// Provides an opportunity for any additional functionality to be managed before the app is started.
    func setUp(_ app: Application) throws
}

public extension ModuleInterface {

    func setUp(_ app: Application) throws {}

    static var identifier: String {
        String(describing: self).dropLast(6).lowercased()
    }
}
