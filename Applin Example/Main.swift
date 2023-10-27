import ApplinIos
import OSLog
import UIKit

@main
class Main: UIResponder, UIApplicationDelegate {
    static let logger = Logger(subsystem: "Example", category: "Main")
    static let FIRST_STARTUP_PAGE_KEY = "/startup"
    static let TERMS_PAGE_KEY = "/terms"
    static let PRIVACY_PAGE_KEY = "/privacy"

    public static func firstStartupPage(_ config: ApplinConfig, _ pageKey: String) -> ToPageSpec {
        PlainPageSpec(title: "Legal Form", ColumnSpec([
            ImageSpec(url: "asset:///logo.png", aspectRatio: 1.67, disposition: .fit),
            TextSpec("To use this app, you must agree to the Terms of Use and be at least 18 years old."),
            FormSpec([
                NavButtonSpec(text: "Terms of Use", [.push(TERMS_PAGE_KEY)]),
                NavButtonSpec(text: "Privacy Policy", [.push(PRIVACY_PAGE_KEY)]),
            ]),
            FormButtonSpec(text: "I Agree and I am 18+ Years Old", [.replaceAll("/")]),
        ]))
    }

    public static func privacyPage(_ config: ApplinConfig, _ pageKey: String) -> ToPageSpec {
        let bytes = try! readBundleFile(filepath: "/privacy.txt")
        let string = String(data: bytes, encoding: String.Encoding.utf8)!
        return NavPageSpec(
                pageKey: pageKey,
                title: "Privacy Policy",
                ScrollSpec(pull_to_refresh: false, TextSpec(string))
        )
    }

    public static func termsPage(_ config: ApplinConfig, _ pageKey: String) -> ToPageSpec {
        let bytes = try! readBundleFile(filepath: "/terms.txt")
        let string = String(data: bytes, encoding: String.Encoding.utf8)!
        return NavPageSpec(
                pageKey: pageKey,
                title: "Terms of Use",
                ScrollSpec(pull_to_refresh: false, TextSpec(string))
        )
    }

    let applinApp: ApplinApp
    var window: UIWindow?

    override init() {
        // Note: This code runs during app prewarming.
        do {
            URLCache.shared = URLCache(memoryCapacity: 10 * 1024 * 1024, diskCapacity: 500 * 1024 * 1024, diskPath: nil)
            let config = try ApplinConfig(
                    // Required
                    appStoreAppId: 0,
                    showPageOnFirstStartup: Self.FIRST_STARTUP_PAGE_KEY,
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
                        Self.FIRST_STARTUP_PAGE_KEY: Self.firstStartupPage,
                        Self.TERMS_PAGE_KEY: Self.termsPage,
                        Self.PRIVACY_PAGE_KEY: Self.privacyPage,
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
