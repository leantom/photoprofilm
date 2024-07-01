//
//  Constants.swift
//  colorful-room
//
//  Created by Ping9 on 16/01/2022.
//

import Foundation

public class Constants{
    static var supportFilters:[FilterModel] = [
        FilterModel("Brightness", image: "sun.max", edit: EditMenu.exposure),
        FilterModel("Contrast", image: "circle.righthalf.filled.inverse", edit: EditMenu.contrast),
        FilterModel("Saturation", image: "snowflake.circle", edit: EditMenu.saturation),
        FilterModel("White Blance",image:"moon.stars.fill", edit: EditMenu.white_balance),
        FilterModel("Tone",image: "cloud.sun.rain", edit: EditMenu.tone),
        FilterModel("HSL",image: "thermometer.sun.fill", edit: EditMenu.hls),
        FilterModel("Fade", image: "drop.degreesign", edit: EditMenu.fade),
    ]
}
