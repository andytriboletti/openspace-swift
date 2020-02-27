//
//  Utils.swift
//  Open Space
//
//  Created by Andy Triboletti on 2/20/20.
//  Copyright © 2020 GreenRobot LLC. All rights reserved.
//

import Foundation
import UIKit
class Utils {
class func colorizeImage(_ image: UIImage?, with color: UIColor?) -> UIImage? {
    UIGraphicsBeginImageContextWithOptions(image?.size ?? CGSize.zero, _: false, _: image?.scale ?? 0.0)

    let context = UIGraphicsGetCurrentContext()
    let area = CGRect(x: 0, y: 0, width: image?.size.width ?? 0.0, height: image?.size.height ?? 0.0)

    context?.scaleBy(x: 1, y: -1)
    context?.translateBy(x: 0, y: -area.size.height)

    context?.saveGState()
    context?.clip(to: area, mask: (image?.cgImage)!)

    color?.set()
    context?.fill(area)

    context?.restoreGState()

    if let context = context {
        context.setBlendMode(.multiply)
    }

    context!.draw((image?.cgImage)!, in: area)

    let colorizedImage = UIGraphicsGetImageFromCurrentImageContext()

    UIGraphicsEndImageContext()

    return colorizedImage
}

}
