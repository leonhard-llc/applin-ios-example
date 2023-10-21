import ApplinIos
import OSLog
import UIKit

@main
class Main: UIResponder, UIApplicationDelegate {
    static let logger = Logger(subsystem: "Example", category: "Main")
    let applinApp: ApplinApp
    var window: UIWindow?

    override init() {
        // Note: This code runs during app prewarming.
        do {
            URLCache.shared = URLCache(memoryCapacity: 10 * 1024 * 1024, diskCapacity: 500 * 1024 * 1024, diskPath: nil)
            let config = try ApplinConfig(
                    // Required
                    appStoreAppId: 0,
                    showPageOnFirstStartup: "/legal_form",
                    staticPages: [
                        // Required
                        StaticPageKeys.APPLIN_CLIENT_ERROR: StaticPages.applinClientError,
                        StaticPageKeys.APPLIN_PAGE_NOT_LOADED: StaticPages.pageNotLoaded,
                        StaticPageKeys.APPLIN_NETWORK_ERROR: StaticPages.applinNetworkError,
                        StaticPageKeys.APPLIN_SERVER_ERROR: StaticPages.applinServerError,
                        StaticPageKeys.APPLIN_STATE_LOAD_ERROR: StaticPages.applinStateLoadError,
                        StaticPageKeys.APPLIN_USER_ERROR: StaticPages.applinUserError,
                        // Optional
                        StaticPageKeys.ERROR_DETAILS: StaticPages.errorDetails,
                        StaticPageKeys.SERVER_STATUS: StaticPages.serverStatus,
                        StaticPageKeys.SUPPORT: StaticPages.support,
                        "/legal_form": StaticPages.legalForm,
                        StaticPageKeys.TERMS: StaticPages.terms,
                        StaticPageKeys.PRIVACY_POLICY: StaticPages.privacyPolicy,
                    ],
                    urlForDebugBuilds: URL(string: "http://192.168.0.2:8000/")!,
                    urlForSimulatorBuilds: URL(string: "http://127.0.0.1:8000/")!,
                    licenseKey: nil, // ApplinLicenseKey("DSZKrGaWAUymZXezLAA,https://app.example.com/"),
                    // Optional
                    statusPageUrl: URL(string: "https://status.example.com/")!,
                    supportChatUrl: URL(string: "https://www.example.com/support")!,
                    supportEmailAddress: "info@example.com",
                    supportSmsTel: "+10005551111"
            )
            self.applinApp = ApplinApp(config)
        } catch let e {
            Self.logger.fault("error starting app: \(e)")
            fatalError("error starting app: \(e)")
        }
        super.init()
    }

    // impl UIApplicationDelegate

    func application(
            _ application: UIApplication,
            didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // https://betterprogramming.pub/creating-ios-apps-without-storyboards-42a63c50756f
        self.window = UIWindow(frame: UIScreen.main.bounds)
        let _ = self.applinApp.application(didFinishLaunchingWithOptions: launchOptions)
        self.window!.rootViewController = self.applinApp.navigationController
        self.window!.makeKeyAndVisible()
        return true
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        self.applinApp.applicationDidBecomeActive()
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        self.applinApp.applicationDidEnterBackground()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        self.applinApp.applicationWillTerminate()
    }
}
