//
//  OSCKit.swift
//  ThreeSixtyCamera
//
//  Created by Zhigang Fang on 4/17/17.
//  Copyright © 2017 Tappollo Inc. All rights reserved.
//
import SwiftyyJSON
import SystemConfiguration.CaptiveNetwork

public class OSCKit {
    public static let shared = OSCKit()

    enum SDKError: Error {
        case unableToParse(JSON)
        case unableToFindImageAt(URL)
        case fetchTimeout
        case unableToFindCacheFolder
        case unableToFindVideo
        case unableToCreateVideoCacheKey
        case unableToParseMetadata
    }

    private init() { }

    public func isConnectedToDeviceWiFi(withPrefix prefix: String) -> Bool {
        return SSID.current?.hasPrefix(prefix) == true
    }
}

struct SSID {
    static var current: String? {
        if let interfaces = CNCopySupportedInterfaces() {
            for i in 0..<CFArrayGetCount(interfaces) {
                let interfaceName: UnsafeRawPointer = CFArrayGetValueAtIndex(interfaces, i)
                let rec = unsafeBitCast(interfaceName, to: AnyObject.self)
                let unsafeInterfaceData = CNCopyCurrentNetworkInfo("\(rec)" as CFString)
                if let interfaceData: NSDictionary = unsafeInterfaceData, let ssid = interfaceData["SSID"] as? String {
                    return ssid
                }
            }
        }
        return nil
    }
}
