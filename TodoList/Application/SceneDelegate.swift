import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        let todoListViewController = TodoListViewController(viewModel: TodoListViewModel())

        let rootViewController = UINavigationController(rootViewController: todoListViewController)

        guard let scene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: scene)
        window?.rootViewController = rootViewController
        window?.makeKeyAndVisible()
    }
}
