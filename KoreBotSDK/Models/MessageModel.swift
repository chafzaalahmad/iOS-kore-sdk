//
//  MessageModel.swift
//  KoreBotSDK
//
//  Created by developer@kore.com on 30/05/16.
//  Copyright © 2016 Kore Inc. All rights reserved.
//

import UIKit
import Mantle

open class MessageModel: MTLModel, MTLJSONSerializing {
    // MARK: properties
    @objc open var type: String?
    @objc open var clientId: String?
    @objc open var component: ComponentModel?
    @objc open var cInfo: NSDictionary?
    @objc open var botInfo: AnyObject?
    
    // MARK: MTLJSONSerializing methods
    public static func jsonKeyPathsByPropertyKey() -> [AnyHashable : Any]! {
        return ["type":"type",
                "component":"component",
                "cInfo":"cInfo"]
    }
    @objc public static func componentJSONTransformer() -> ValueTransformer {
        return ValueTransformer.mtl_JSONDictionaryTransformer(withModelClass: ComponentModel.self)
    }
}

open class BotMessageModel: MTLModel, MTLJSONSerializing {
    // MARK: properties
    @objc open var type: String?
    @objc open var iconUrl: String?
    @objc open var messages: Array<MessageModel> = [MessageModel]()
    @objc open var createdOn: Date?
    @objc open var messageId: String?
    // MARK: MTLJSONSerializing methods
    public static func jsonKeyPathsByPropertyKey() -> [AnyHashable : Any]! {
        return ["type":"type",
                "iconUrl":"icon",
                "messages":"message",
                "messageId":"messageId",
                "createdOn":"createdOn"]
    }
    
    @objc public static func messagesJSONTransformer() -> ValueTransformer {
        return ValueTransformer.mtl_JSONArrayTransformer(withModelClass: MessageModel.self)
    }
    
    @objc public static func createdOnJSONTransformer() -> ValueTransformer {
        return MTLValueTransformer.reversibleTransformer(forwardBlock: { (dateString) in
            return self.dateFormatter().date(from: dateString as! String)
            }, reverse: { (date) in
                return nil
        })
    }
    
    public static func dateFormatter() -> DateFormatter {
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        return dateFormatter
    }
}

open class Ack: MTLModel, MTLJSONSerializing {
    // MARK: properties
    @objc open var status: Bool = false
    @objc open var clientId: String?
    
    // MARK: MTLJSONSerializing methods
    public static func jsonKeyPathsByPropertyKey() -> [AnyHashable : Any]! {
        return ["status":"ok",
                "clientId":"replyto"]
    }
}


// MARK: - BotMessage
open class BotMessages: MTLModel, MTLJSONSerializing {
    @objc open var createdBy: String?
    @objc open var createdOn: Date?
    @objc open var lmodifiedOn: String?
    @objc open var resourceid: String?
    @objc open var tN: String?
    @objc open var type: String?
    @objc open var components: [BotMessageComponents]?
    //    @objc open var channels: String?
    @objc open var botId: String?
    @objc open var messageId: String?
    
    
    public static func jsonKeyPathsByPropertyKey() -> [AnyHashable : Any]! {
        return ["createdBy": "createdBy",
                "createdOn": "createdOn",
                "lmodifiedOn": "lmodifiedOn",
                "resourceid": "resourceid",
                "tN": "tN",
                "type": "type",
                "components": "components",
                "botId": "botId",
                "messageId": "_id"
        ]
    }
    
    @objc public static func componentsJSONTransformer() -> ValueTransformer {
        return MTLJSONAdapter.arrayTransformer(withModelClass: BotMessageComponents.self)
    }
    
    @objc public static func createdOnJSONTransformer() -> ValueTransformer {
        return MTLValueTransformer.reversibleTransformer(forwardBlock: { (dateString) in
            return self.dateFormatter().date(from: dateString as! String)
        }, reverse: { (date) in
            return nil
        })
    }
    
    public static func dateFormatter() -> DateFormatter {
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        return dateFormatter
    }
}

// MARK: - BotMessageComponents
open class BotMessageComponents: MTLModel, MTLJSONSerializing {
    @objc open var data : [String: Any]?
    
    public static func jsonKeyPathsByPropertyKey() -> [AnyHashable : Any]! {
        return ["data": "data"]
    }
}
