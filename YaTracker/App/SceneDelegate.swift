import UIKit
import CoreData

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    var trackerStore: TrackerStore!
    var recordStore: TrackerRecordStore!

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let scene = (scene as? UIWindowScene) else { return }
        
        let container = NSPersistentContainer(name: "ModelSupaStar")
        container.loadPersistentStores { _, error in
            if let error = error { fatalError("Core Data total failure: \(error)") }
        }
        
        trackerStore = TrackerStore(context: container.viewContext)
        recordStore = TrackerRecordStore(context: container.viewContext)
        
        let window = UIWindow(windowScene: scene)
        
        let appearance = UITabBarAppearance()
        appearance.shadowColor = .lightGray
        appearance.backgroundColor = .ypWhite
        
        let tabBarController = UITabBarController()
        tabBarController.viewControllers = [createTrackersVC(), createStatisticsVC()]
        tabBarController.tabBar.scrollEdgeAppearance = appearance
        
        window.rootViewController = tabBarController
        self.window = window
        window.makeKeyAndVisible()
    }
    
    private func createTrackersVC() -> UIViewController {
        let vc = TrackersViewController(trackerStore: trackerStore, recordStore: recordStore)
        vc.tabBarItem = UITabBarItem(
            title: "Трекеры",
            image: UIImage(resource: .tabBarTrackers),
            selectedImage: nil
        )
        return vc
    }
    
    private func createStatisticsVC() -> UIViewController {
        let vc = StatisticsVC()
        vc.tabBarItem = UITabBarItem(
            title: "Статистика",
            image: UIImage(resource: .tabBarStatistics),
            selectedImage: nil
        )
        return vc
    }

    func sceneDidDisconnect(_ scene: UIScene) { }

    func sceneDidBecomeActive(_ scene: UIScene) { }

    func sceneWillResignActive(_ scene: UIScene) { }

    func sceneWillEnterForeground(_ scene: UIScene) { }

    func sceneDidEnterBackground(_ scene: UIScene) { }
}

