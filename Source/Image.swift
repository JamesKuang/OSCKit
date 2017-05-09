//
//  Image.swift
//  ThreeSixtyCamera
//
//  Created by Zhigang Fang on 4/18/17.
//  Copyright © 2017 Tappollo Inc. All rights reserved.
//

import Foundation
import SwiftyyJSON
import PromiseKit
import AwaitKit

public enum DownloadType: String {
    case thumbnail = "thumb"
    case full = "full"
}

extension OSCKit {

    public func getImage(url: String, type: DownloadType = .full) -> Promise<UIImage> {
        return async {
            let url = try await(self.getImageLocalURL(url: url, type: type))

            //TODO: test metadata call
            let imageMetadata = try await(self.getImageMetadata(of: url))
            print("**** is360: \(imageMetadata.is360())")

            return try UIImage(contentsOfFile: url.path) !! SDKError.unableToFindImageAt(url)
        }
    }

    public func getImageLocalURL(url: String, type: DownloadType = .full) -> Promise<URL> {
        return async {
            let device = try await(self.deviceInfo)
            // Adding serial key in the begining
            // To prevent cache collision between different devices
            let cacheKey = try (device.serial + url).addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) !! SDKError.unableToCreateVideoCacheKey
            let cacheFolder = try NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first.map({
                URL(fileURLWithPath: $0)
            }) !! SDKError.unableToFindCacheFolder
            let fileURL = cacheFolder.appendingPathComponent(cacheKey)
            if FileManager.default.fileExists(atPath: fileURL.path) {
                return fileURL
            }
            let data = try await(self.requestData(command: .getImage(fileUri: url, _type: type)))
            try data.write(to: fileURL)
            return fileURL
        }
    }

    public func takePicture() -> Promise<String> {
        return async {
            let session = try await(self.session)
            try await(self.execute(command: .setOptions(options: [CaptureMode.image], sessionId: session.id)))
            try await(self.execute(command: .setOptions(options: [FileFormat.smallImage], sessionId: session.id)))
            let captureResponse = try await(self.execute(command: .takePicture(sessionId: session.id)))
            let statusID = try captureResponse["id"].string !! SDKError.unableToParse(captureResponse)
            let statusResponse = try await(self.waitForStatus(id: statusID))
            return try statusResponse["results"]["fileUri"].string !! SDKError.unableToParse(statusResponse)
        }
    }
}
