//
//  BSFunctions.swift
//  botsocial
//
//  Created by Aamir  on 22/03/18.
//  Copyright © 2018 AamirAnwar. All rights reserved.
//

import Foundation
import Photos

enum BSCommons {
    static func getLatestPhotoFromLibrary(completion:@escaping(_ image:UIImage?)->Void) {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor.init(key: "creationDate", ascending: true)]
        let fetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        if let lastAsset = fetchResult.lastObject {
            PHImageManager.default().requestImage(for: lastAsset, targetSize: CGSize.init(width: kLibPhotoPreviewSize, height: kLibPhotoPreviewSize), contentMode: .aspectFit, options: nil, resultHandler: { (image, info) in
                DispatchQueue.main.async {
                    completion(image)
                }
            })
        }
    }
}


