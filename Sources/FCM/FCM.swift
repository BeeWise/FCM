import Vapor
import Foundation
import JWT

// MARK: Engine

public class FCM {
    let application: Application
    
    let client: Client
    
    let scope = "https://www.googleapis.com/auth/cloud-platform"
    let audience = "https://www.googleapis.com/oauth2/v4/token"
    let actionsBaseURL = "https://fcm.googleapis.com/v1/projects/"
    let iidURL = "https://iid.googleapis.com/iid/v1:"
    let batchURL = "https://fcm.googleapis.com/batch"
    
    public var configuration: FCMConfiguration? {
        didSet {
            if let email = self.configuration?.email {
                self.warmUpCache(with: email)
            }
        }
    }
    var jwt: String?
    var accessToken: String?
    var gAuth: GAuthPayload?
    
    // MARK: Default configurations
    
    public var apnsDefaultConfig: FCMApnsConfig<FCMApnsPayload>? {
        get { configuration?.apnsDefaultConfig }
        set { configuration?.apnsDefaultConfig = newValue }
    }
    
    public var androidDefaultConfig: FCMAndroidConfig? {
        get { configuration?.androidDefaultConfig }
        set { configuration?.androidDefaultConfig = newValue }
    }
    
    public var webpushDefaultConfig: FCMWebpushConfig? {
        get { configuration?.webpushDefaultConfig }
        set { configuration?.webpushDefaultConfig = newValue }
    }
    
    // MARK: Initialization

    init(application: Application, client: Client) {
        self.application = application
        self.client = client
    }

    public convenience init(application: Application) {
        self.init(application: application, client: application.client)
    }

    public convenience init(request: Request) {
        self.init(application: request.application, client: request.client)
    }
    
    private func warmUpCache(with email: String) {
        if self.gAuth == nil {
            self.gAuth = GAuthPayload(iss: email, sub: email, scope: scope, aud: audience)
        }
        if self.jwt == nil {
            do {
                self.jwt = try generateJWT()
            } catch {
                fatalError("FCM Unable to generate JWT: \(error)")
            }
        }
    }
}
