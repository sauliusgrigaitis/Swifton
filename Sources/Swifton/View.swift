import Stencil
import PathKit

protocol View {
    init(_ path: String, _ context: [String: Any]?)
    func render() -> String
}

struct StencilView {
    var template: Template?
    var context: [String: Any]?

    init(_ path: String, _ context: [String: Any]? = nil) {
        let defaultTemplateLoader = TemplateLoader(paths: [Path(SwiftonConfig.viewsDirectory)])
        if context != nil {
            self.context = context
            self.context!["loader"] = defaultTemplateLoader
        } else {
            self.context = ["loader": defaultTemplateLoader]
        }

        var templatePath = path.characters.split {$0 == "/"}.map(String.init)
        let templateName = templatePath.removeLast()

        let appPath = Path(SwiftonConfig.viewsDirectory)
        let paths = [appPath + templatePath.joined(separator: "/")]
        let templateLoader = TemplateLoader(paths: paths)
        self.template = templateLoader.loadTemplate(name: templateName + ".html.stencil")
    }

    func render() -> String {
        guard template != nil else { return "Template Not Found" }
        guard context != nil else { return try! template!.render() }
        return try! template!.render(context: Context(dictionary: context!))
    }
}

struct JSONView {
    var context: [String: Any]?

    init(_ context: [String: Any]? = nil) {
        self.context = context
    }

    func render() -> String {
        guard context != nil else { return "" }
        let json = context!.toJSON()
        return json!
    }
}
