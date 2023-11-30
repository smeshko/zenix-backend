import Vapor
import SwiftHtml

struct OutcomeMessageTemplate: TemplateRepresentable {

    var context: OutcomeMessageContext

    init(
        _ context: OutcomeMessageContext
    ) {
        self.context = context
    }

    @TagBuilder
    func render(
        _ req: Request
    ) -> Tag {
        Html {
            Head {
                Meta()
                    .charset("utf-8")
                Meta()
                    .name(.viewport)
                    .content("width=device-width, initial-scale=1")

                Link(rel: .shortcutIcon)
                    .href("/img/favicon.ico")
                    .type("image/x-icon")
                Link(rel: .stylesheet)
                    .href("https://cdn.jsdelivr.net/gh/feathercms/feather-core@1.0.0-beta.44/feather.min.css")
                Link(rel: .stylesheet)
                    .href("/css/web.css")
                
                Title(context.text)
            }
            Body {                
                Main {
                    Text(context.text)
                }
            }
        }
        .lang("en-US")
    }
}
