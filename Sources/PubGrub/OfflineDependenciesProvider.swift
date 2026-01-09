import Collections
import Foundation

public struct OfflineDependencyProvider<P: Package, V: Version>: PubGrubDependencyProvider {
    public var dependencies: [P: OrderedDictionary<V, DependencyConstraints<P, V>>] = [:]

    public init() {}

    /// Adds a package with dependencies to registry
    public mutating func add(
        _ package: P,
        _ version: V,
        _ dependencies: OrderedDictionary<P, VersionSet<V>>
    ) {
        let v = version
        self.dependencies[package, default: [:]][v] = .init(constraints: dependencies)
    }

    /// Lists packages that have been saved.
    public func packages() -> [P] {
        Array(dependencies.keys)
    }

    /// Lists versions of saved packages in sorted order.
    /// Returns nil if no information is available regarding that package.
    public func versions(package: P) -> [V]? {
        dependencies[package].map { Array($0.keys) }
    }

    /// Lists dependencies of a given package and version.
    /// Returns nil if no information is available regarding that package and version pair.
    public func dependencies(package: P, version: V) -> DependencyConstraints<P, V>? {
        dependencies[package]?[version]
    }

    public func choosePackageVersion(
        potentialPackages: [(P, VersionSet<V>)]
    ) async throws -> (P, V?) {
        try await choosePackageWithFewestVersions(
            listAvailableVersions: { p -> [V] in
                let constrs = dependencies[p]?.keys ?? []
                return Array(constrs)
            },
            potentialPackages: potentialPackages
        )
    }

    public func getDependencies(
        package: P,
        version: V
    ) async throws -> Dependencies<P, V> {
        if let deps = dependencies(package: package, version: version) {
            return .known(deps)
        }
        return .unknown
    }
}
