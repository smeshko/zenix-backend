@testable import App
import Framework
import Vapor

protocol TestRepository: AnyObject {}

extension TestRepository where Self: RequestService {
    func `for`(_ req: Request) -> Self {
        return self
    }
}
