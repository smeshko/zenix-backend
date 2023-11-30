import Vapor
import SwiftHtml

struct ResetPasswordTemplate: TemplateRepresentable {

    var context: ResetPasswordContext
    
    init(
        _ context: ResetPasswordContext
    ) {
        self.context = context
    }

    @TagBuilder
    func render(
        _ req: Request
    ) -> Tag {
        WebIndexTemplate(
            .init(title: context.title)
        ) {
            Div {
                Section {
                    P(context.icon)
                    H1(context.title)
                    P(context.message)
                }
                .class("lead")

                context.form.render(req)
            }
            .id("user-login")
            .class("container")
        }
        .render(req)
    }
}
