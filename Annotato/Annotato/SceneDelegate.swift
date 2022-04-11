import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    private let webSocketManager = WebSocketManager(urlStringProducer: {
        guard let userId = AuthViewModel().currentUser?.id else {
            return nil
        }

        return RemotePersistenceService.generateWebSocketUrlString(userId: userId)
    })

    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions
    ) {
        // Use this method to optionally configure and attach the UIWindow
        // `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically
        // be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new
        // (see `application:configurationForConnectingSceneSession` instead).

        // swiftlint:disable unused_optional_binding
        guard let _ = (scene as? UIWindowScene) else {
            return
        }

        let documentListViewController = DocumentListViewController.instantiateFullScreenFromStoryboard(.document)
        documentListViewController?.webSocketManager = webSocketManager

        window?.rootViewController = AuthViewModel().currentUser != nil
            ? documentListViewController
            : AuthViewController.instantiateFullScreenFromStoryboard(.main)
    }

    func changeRootViewController(newRootViewController: UIViewController, animated: Bool = true) {
        guard let window = self.window else {
            return
        }

        window.rootViewController = newRootViewController

        if animated {
            UIView.transition(with: window,
                              duration: 0.5,
                              options: [.transitionCrossDissolve],
                              animations: nil,
                              completion: nil)
        }

        if let newRootViewController = newRootViewController as? DocumentListViewController {
            newRootViewController.webSocketManager = webSocketManager
            webSocketManager.setUpSocket()
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded
        // (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.

        // Set up socket when application launches from background (Multi-tasking)
        webSocketManager.setUpSocket()
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
}
