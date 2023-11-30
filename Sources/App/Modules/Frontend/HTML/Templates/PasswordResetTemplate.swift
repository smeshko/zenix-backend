//import Vapor
//import SwiftHtml
//
//struct PasswordResetTemplate: TemplateRepresentable {
//    
//    var context: PasswordResetContext
//    
//    init(
//        _ context: PasswordResetContext
//    ) {
//        self.context = context
//    }
//    
//    @TagBuilder
//    func render(
//        _ req: Request
//    ) -> Tag {
//        Div {
//            Form {
//                Section {
//                    Label("Password:")
//                        .for("password")
//                    Input()
//                        .key("password")
//                        .type(.password)
//                        .value(context.password)
//                        .class("field")
//                }
//                Section {
//                    Label("Confirm Password:")
//                        .for("confirm_password")
//                    Input()
//                        .key("confirm_password")
//                        .type(.password)
//                        .value(context.confirmPassword)
//                        .class("field")
//                }
//                Section {
//                    Input()
//                        .type(.submit)
//                        .value("Submit")
//                        .class("submit")
//                }
//            }
//            .action("/reset-password?token=\(context.token)")
//            .method(.post)
//        }
//        .id("user-login")
//        .class("container")
//    }
//}
