import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        let todoListViewModel = TodoListViewModel(
            fileCache: FileCache(filename: Res.fileStorageName),
            networkService: YandexNetworkingService(),
            retryManager: RetryManager()
        )

        let todoListViewController = TodoListViewController(viewModel: todoListViewModel)

        let rootViewController = UINavigationController(rootViewController: todoListViewController)

        guard let scene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: scene)
        window?.rootViewController = rootViewController
        window?.makeKeyAndVisible()
    }
}
