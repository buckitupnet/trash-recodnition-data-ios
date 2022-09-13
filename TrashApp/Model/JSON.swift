//
//  JSON.swift
//  TrashApp
//
//  Created by Volodymyr Nazarkevych on 08.07.2022.
//

import Foundation

struct JSONModel: Codable {
    var version: String
    var flags: Flags?
    var shapes: [Shape]
    var imagePath: String
    var imageData: String
    var imageHeight: Int
    var imageWidth: Int

    internal init(version: String, flags: Flags? = Flags(), shapes: [Shape], imagePath: String, imageData: String, imageHeight: Int, imageWidth: Int) {
        self.version = version
        self.flags = flags
        self.shapes = shapes
        self.imagePath = imagePath
        self.imageData = imageData
        self.imageHeight = imageHeight
        self.imageWidth = imageWidth
    }
}

struct Shape: Codable {
    var label: String
    var points: [[Double]]
    var group_id: Int?
    var shape_type: String
    var flags: Flags?
    
    internal init(label: String, points: [[Double]], group_id: Int? = nil, shape_type: String, flags: Flags? = Flags()) {
        self.label = label
        self.points = points
        self.group_id = group_id
        self.shape_type = shape_type
        self.flags = flags
    }
}

struct Flags: Codable {}

