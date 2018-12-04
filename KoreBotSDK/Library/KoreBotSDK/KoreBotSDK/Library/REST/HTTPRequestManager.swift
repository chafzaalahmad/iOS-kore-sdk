//
//  HTTPRequestManager.swift
//  KoreBotSDK
//
//  Created by developer@kore.com on 21/04/16.
//  Copyright © 2016 Kore Inc. All rights reserved.
//

import Foundation
import AFNetworking
import Mantle
import CoreData

open class HTTPRequestManager : NSObject {
    var options: AnyObject?
    static var instance: HTTPRequestManager!
    
    var sessionManager: AFHTTPSessionManager?
    

    // MARK: request manager shared instance
    open static let sharedManager : HTTPRequestManager = {
        if (instance == nil) {
            instance = HTTPRequestManager()
            instance.configureSessionManager()
        }
        return instance
    }()
    
    func configureSessionManager() {
        
        // Session Configuration
        let configuration = URLSessionConfiguration.default
        
        //Manager
        sessionManager = AFHTTPSessionManager.init(baseURL: URL.init(string: Constants.URL.baseUrl) as URL?, sessionConfiguration: configuration)
        
        // Request
        let requestSerializer = AFJSONRequestSerializer()
        requestSerializer.httpMethodsEncodingParametersInURI = Set.init(["GET"]) as Set<String>
        requestSerializer.setValue("Keep-Alive", forHTTPHeaderField:"Connection")
        requestSerializer.setValue("application/json", forHTTPHeaderField:"Content-Type")

        sessionManager?.requestSerializer = requestSerializer
        
        // Response
        sessionManager?.responseSerializer = AFJSONResponseSerializer.init()
    }
    
    // MARK: requests
    open func signInWithToken(_ token: String, botInfo: [String: Any], success:((_ user: UserModel?, _ authInfo: AuthInfoModel?) -> Void)?, failure:((_ error: Error) -> Void)?)  {
        let urlString: String = Constants.URL.jwtAuthorizationUrl
        let parameters: NSDictionary = ["assertion": token, "botInfo": botInfo]

        sessionManager?.post(urlString, parameters: parameters, progress: { (progress) in
            
        }, success: { (dataTask, responseObject) in
            if responseObject is [AnyHashable: Any] {
                let dictionary = responseObject as! [String : AnyObject]
                let authorization: [AnyHashable: Any] = dictionary["authorization"] as! [AnyHashable: Any]
                let userInfo: [AnyHashable: Any] = dictionary["userInfo"] as! [AnyHashable: Any]
                let authInfo: AuthInfoModel = try! (MTLJSONAdapter.model(of: AuthInfoModel.self, fromJSONDictionary: authorization) as! AuthInfoModel)
                let user: UserModel = try! (MTLJSONAdapter.model(of: UserModel.self, fromJSONDictionary: userInfo) as! UserModel)
                success?(user, authInfo)
            } else {
                failure?(NSError(domain: "", code: 0, userInfo: [:]))
            }
        }) { (dataTask, error) in
            failure?(error)
        }
    }
    
    open func getRtmUrlWithAuthInfoModel(_ authInfo: AuthInfoModel, botInfo: [String: Any], success:((_ botInfo: BotInfoModel?) -> Void)?, failure:((_ error: Error) -> Void)?)  {
        let urlString: String = Constants.URL.rtmUrl
        let accessToken: String = String(format: "%@ %@", authInfo.tokenType!, authInfo.accessToken!)
        sessionManager?.requestSerializer.setValue(accessToken, forHTTPHeaderField:"Authorization")

        let parameters: NSDictionary = ["botInfo": botInfo, "authorization": accessToken]

        sessionManager?.post(urlString, parameters: parameters, progress: { (progress) in
            
        }, success: { (dataTask, responseObject) in
            let botInfo: BotInfoModel = try! (MTLJSONAdapter.model(of: BotInfoModel.self, fromJSONDictionary: responseObject! as! [AnyHashable: Any]) as! BotInfoModel)
            success?(botInfo)
           
        }) { (dataTask, error) in
            failure?(error)
        }
    }
    
    open func getHistory(_ messageID: String,_ authInfo: AuthInfoModel, botInfo: [String: Any], success:((_ responseObject: [String: Any]?) -> Void)?, failure:((_ error: Error) -> Void)?)  {
        let urlString: String = Constants.URL.historyUrl
         let accessToken: String = String(format: "%@ %@", authInfo.tokenType!, authInfo.accessToken!)
         sessionManager?.requestSerializer.setValue(accessToken, forHTTPHeaderField:"Authorization")
        let parameters: NSDictionary = ["botId": botInfo["taskBotId"],"msgId": messageID, "forward": "true", "limit": "100"]
        
        sessionManager?.get(urlString, parameters: parameters, progress: { (progress) in
            
        }, success: { (dataTask, responseObject) in
            if (responseObject is [String: Any]) {
                success?(responseObject as? [String : Any])
            } else {
                failure?(NSError(domain: "", code: 0, userInfo: [:]))
            }
        }) { (dataTask, error) in
            failure?(error)
        }
    }
    
    // MARK: subscribe/ unsubscribte for
    open func subscribeToNotifications(_ deviceToken: Data!, userInfo: UserModel!, authInfo: AuthInfoModel!, success:((_ staus: Bool) -> Void)?, failure:((_ error: Error) -> Void)?) {
        let urlString: String = Constants.URL.subscribeUrl(userInfo.userId)
        
        let accessToken: String = String(format: "%@ %@", authInfo.tokenType!, authInfo.accessToken!)
        sessionManager?.requestSerializer.setValue(accessToken, forHTTPHeaderField:"Authorization")

        let deviceId: String! = deviceToken.hexadecimal()
        if (deviceId == nil) {
            failure?(NSError(domain: "KoreBotSDK", code: 0, userInfo: ["message": "deviceId is nil"]))
            return
        }
        let parameters: NSDictionary = ["deviceId": deviceId, "osType": "ios"]
        
        sessionManager?.post(urlString, parameters: parameters, progress: { (progress) in
            
        }, success: { (dataTask, responseObject) in
            success?(true)
        }) { (dataTask, error) in
            failure?(error)
        }
    }
    
    open func unsubscribeToNotifications(_ deviceToken: Data!, userInfo: UserModel!, authInfo: AuthInfoModel!, success:((_ staus: Bool) -> Void)?, failure:((_ error: Error) -> Void)?) {
        let urlString: String = Constants.URL.unSubscribeUrl(userInfo.userId)
        
        let accessToken: String = String(format: "%@ %@", authInfo.tokenType!, authInfo.accessToken!)
        sessionManager?.requestSerializer.setValue(accessToken, forHTTPHeaderField:"Authorization")
        
        let deviceId: String! = deviceToken.hexadecimal()
        if (deviceId == nil) {
            failure?(NSError(domain: "KoreBotSDK", code: 0, userInfo: ["message": "deviceId is nil"]))
            return
        }
        
        let parameters: NSDictionary = ["deviceId": deviceId]
        
        sessionManager?.delete(urlString, parameters: parameters, success: { (operation, responseObject) in
            success?(true)
        }) { (operation, error) in
            failure?(error)
        }
    }
}

extension Data {
    func hexadecimal() -> String {
        return map { String(format: "%02x", $0) }
            .joined(separator: "")
    }
}
