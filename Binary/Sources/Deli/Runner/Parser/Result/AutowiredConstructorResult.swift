//
//  AutowiredConstructorResult.swift
//  Deli
//

final class AutowiredConstructorResult: Results {
    var isLazy: Bool { return false }
    var instanceType: String
    var scope: String?
    var qualifier: String?
    var dependencies: [Dependency]

    var linkType: Set<String> = Set()

    var instanceDependency: [Dependency]
    
    init(_ instanceType: String, _ scope: String?, _ qualifier: String?, _ dependencies: [Dependency]) {
        self.instanceType = instanceType
        self.scope = scope
        self.qualifier = qualifier
        self.dependencies = dependencies
        self.instanceDependency = dependencies
    }
    func makeSource() -> String? {
        let linkString = linkType
            .map { ".link(\($0).self)" }
            .joined(separator: "")

        let dependencyResolve = instanceDependency
            .map { dependency in
                switch dependency.type {
                case .single:
                    return "let _\(dependency.name) = context.get(\(dependency.name).self, qualifier: \"\")!"
                case .array:
                    return "let _\(dependency.name) = context.get([\(dependency.name)].self, qualifier: \"\")"
                }
            }
            .joined(separator: "\n        ")

        let dependencyInject = instanceDependency
            .map { "_\($0.name)" }
            .joined(separator: ", ")

        return """
        context.register(
            \(instanceType).self,
            resolver: {
                \(dependencyResolve)
                return \(instanceType)(\(dependencyInject))
            },
            qualifier: "\(qualifier ?? "")",
            scope: \(scope ?? ".singleton")
        )\(linkString)
        """
    }
}
