//
//  DataModels.swift
//  IPSWNibbler
//
//  Created by Kim David Hauser on 06.12.2023.
//

import Foundation

let BASE_IPSW_API_URL : String = "https://api.ipsw.me/v4/"

enum IPSWAPIFunction: Identifiable, CaseIterable {
    case selectFunction
    case device
    case devices
    case devicesOnlyKeys
    case firmwares
    case downloadIPSW
    case IPSWInfo
    case IPSWVersion
    case downloadITunes
    case iTunesPlatform
    case keysDeviceList
    case keysIPSWList
    case model
    case otaDoc
    case otaDownload
    case otaInfo
    case otaVersion
    case releases

    var id: Int {
        switch self {
        case .selectFunction: return -1
        case .device: return 0
        case .devices: return 1
        case .devicesOnlyKeys: return 2
        case .firmwares: return 3
        case .downloadIPSW: return 4
        case .IPSWInfo: return 5
        case .IPSWVersion: return 6
        case .downloadITunes: return 7
        case .iTunesPlatform: return 8
        case .keysDeviceList: return 9
        case .keysIPSWList: return 10
        case .model: return 11
        case .otaDoc: return 12
        case .otaDownload: return 13
        case .otaInfo: return 14
        case .otaVersion: return 15
        case .releases: return 16
        }
    }

    var stringValue: String {
        switch self {
        case .selectFunction: return "- Select Function -"
        case .device: return "Get Firmwares for Device"
        case .devices: return "Get Devices"
        case .devicesOnlyKeys: return "Get Devices (only with keys)"
        case .firmwares: return "Firmwares"
        case .downloadIPSW: return "Download IPSW"
        case .IPSWInfo: return "Get IPSW Information"
        case .IPSWVersion: return "Get IPSW List for Version"
        case .downloadITunes: return "Download iTunes installer"
        case .iTunesPlatform: return "Download iTunes installer (by platform)"
        case .keysDeviceList: return "Firmwares which have keys (for device)"
        case .keysIPSWList: return "Firmwares which have keys (for IPSW)"
        case .model: return "Identifier of a given model number"
        case .otaDoc: return "OTA Documentation"
        case .otaDownload: return "OTA Downloads"
        case .otaInfo: return "OTA Information"
        case .otaVersion: return "OTA Versions"
        case .releases: return "Release timeline of all entities"
        }
    }
    
    var url: String {
        switch self {
//        case .selectFunction: return "- Select Function -"
//        case .device: return "Get Firmwares for Device"
//        case .devices: return "Get Devices"
//        case .devicesOnlyKeys: return "Get Devices (only with keys)"
//        case .firmwares: return "Firmwares"
//        case .downloadIPSW: return "Download IPSW"
//        case .IPSWInfo: return "Get IPSW Information"
//        case .IPSWVersion: return "Get IPSW List for Version"
//        case .downloadITunes: return "Download iTunes installer"
//        case .iTunesPlatform: return "Download iTunes installer (by platform)"
//        case .keysDeviceList: return "Firmwares which have keys (for device)"
//        case .keysIPSWList: return "Firmwares which have keys (for IPSW)"
//        case .model: return "Identifier of a given model number"
//        case .otaDoc: return "OTA Documentation"
//        case .otaDownload: return "OTA Downloads"
//        case .otaInfo: return "OTA Information"
//        case .otaVersion: return "OTA Versions"
        case .releases: return "release"
        default: return "devices"
        }
//        return "device"
    }
}

struct ReleaseModel: Codable {
    let name: String
    let date: String
    let count: Int
    let type: String
}

struct ReleaseDateModel: Codable {
    let date: String
    let releases: [ReleaseModel]
}

struct FirmawareModel: Codable {
    let identifier: String
    let version: String
    let buildid: String
    let sha1sum: String
    let md5sum: String
    let sha256sum: String
    let filesize: Double
    let url: String
    let releasedate: String?
    let uploaddate: String?
    let signed: Bool
}

struct DeviceModelNG3: Codable {
    let name: String
    let identifier: String
    let firmwares: [FirmawareModel]
    let boards: [BoardModel]
    let boardconfig: String
    let platform: String
    let cpid: Int
    let bdid: Int
}

struct BoardModel: Codable {
    let boardconfig: String
    let platform: String
    let cpid: Int
    let bdid: Int
}

struct DeviceModelNG2: Codable {
    let name: String
    let identifier: String
    let boards: [BoardModel]
    let boardconfig: String
    let platform: String
    let cpid: Int
    let bdid: Int
}

struct DeviceModel: Codable {
    let identifier: String
    let buildid: String
    let codename: String
    let updateramdiskexists: Bool
    let restoreramdiskexists: Bool
}

class TreeNodeNG2: Identifiable {
    var id = UUID()
    var name: String
    var desc: String
    var children: [TreeNodeNG2]?

    init(name: String, desc: String, children: [TreeNodeNG2]? = nil) {
        self.name = name
        self.desc = desc
        self.children = children
    }
}
