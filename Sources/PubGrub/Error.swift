import Foundation

/// Errors that may occur while solving dependencies.
public enum PubGrubError<P: Package, V: Version>: Error {
    /// There is no solution for this set of dependencies.
    case noSolution(DerivationTree<P, V>)

    /// Error arising when the implementer of DependencyProvider
    /// returned an error in the method getDependencies
    case errorRetrievingDependencies(
        /// Package whose dependencies we want.
        package: P,
        /// Version of the package for which we want the dependencies.
        version: V
    )

    /// Error arising when the implementer of DependencyProvider
    /// returned a dependency on an empty range.
    /// This technically means that the package can not be selected,
    /// but is clearly some kind of mistake.
    case dependencyOnTheEmptySet(
        /// Package whose dependencies we want.
        package: P,
        /// Version of the package for which we want the dependencies.
        version: V,
        /// The dependent package that requires us to pick from the empty set.
        dependent: P
    )

    /// Error arising when the implementer of DependencyProvider
    /// returned a dependency on the requested package.
    /// This technically means that the package directly depends on itself,
    /// and is clearly some kind of mistake.
    case selfDependency(
        /// Package whose dependencies we want.
        package: P,
        /// Version of the package for which we want the dependencies.
        version: V
    )

    /// Error arising when the implementer of DependencyProvider
    /// returned an error in the method choosePackageVersion
    case errorChoosingPackageVersion(String)

    /// Error arising when the implementer of DependencyProvider
    /// returned an error in the method shouldCancel
    case errorInShouldCancel(Error)

    /// Something unexpected happened.
    case failure(String)
}

extension PubGrubError: CustomStringConvertible {
    public var description: String {
        switch self {
        case .noSolution:
            return "No solution"
        case let .errorRetrievingDependencies(package, version):
            return "Retrieving dependencies of \(package.name) \(version) failed"
        case let .dependencyOnTheEmptySet(package, version, dependent):
            return "Package \(dependent.name) required by \(package.name) \(version) depends on the empty set"
        case let .selfDependency(package, version):
            return "\(package.name) \(version) depends on itself"
        case let .errorChoosingPackageVersion(err):
            return "Decision making failed: \(err)"
        case let .errorInShouldCancel(err):
            return "We should cancel: \(err)"
        case let .failure(str):
            return str
        }
    }
}
