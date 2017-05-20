//
//  Options.swift
//  ThreeSixtyCamera
//
//  Created by Zhigang Fang on 4/18/17.
//  Copyright © 2017 Tappollo Inc. All rights reserved.
//

import Foundation
import SwiftyyJSON

protocol Option {
    var key: String { get }
    var value: JSON { get }
}

enum CaptureMode: String, Option {
    case video = "_video"
    case image = "image"
    var key: String { return "captureMode" }
    var value: JSON { return JSON(value: self.rawValue as NSObject) }
}

public struct FileFormat: Option {

    let type: String
    let width: Int
    let height: Int

    var key: String { return "fileFormat" }
    var value: JSON { return ["type": type, "width": width, "height": height] }

    static let smallImage = FileFormat(type: "jpeg", width: 2048, height: 1024)
    static let largeImage = FileFormat(type: "jpeg", width: 5376, height: 2688)
}
