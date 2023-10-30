import Entities

extension User: ApiModuleInterface {}

extension User.Account: ApiModelInterface {
    public typealias Module = User
}

extension User.Token: ApiModelInterface {
    public typealias Module = User
}
