@preconcurrency import ProjectDescription

let workspace = Workspace(
    name: "AppWithDynamicFrameworkAndBundles",
    projects: [
        "./"
    ],
    generationOptions: .options(
        autogenerateLocalPodsProjects: .automatic(
            [
                "LocalPods/**/*.podspec"
            ]
        ),
        configurations: [
            "Debug": .debug,
            "Release": .release
        ]
    )
)
