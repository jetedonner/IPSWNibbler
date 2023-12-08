//
//  SwiftUIView-Ext-FetchData.swift
//  IPSWNibbler
//
//  Created by Kim David Hauser on 07.12.2023.
//

import SwiftUI

extension SwiftUIView{
    func fetchData<T: Decodable>(apiUrl: String = "\(BASE_IPSW_API_URL)releases", responseType: T.Type) async throws -> T {
        guard let url = URL(string: apiUrl) else {
            fatalError("Invalid URL")
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            print("Received data: \(String(data: data, encoding: .utf8) ?? "Empty")")

            let decoder = JSONDecoder()
            let decodedData = try decoder.decode(T.self, from: data)
            return decodedData
        } catch {
            print("Error fetching data: \(error)")
            throw error
        }
    }
    
    func getStruct(devices:[DeviceModel]) -> [TreeNodeNG2] {
        var nodes: [TreeNodeNG2] = []
        var currCodeName: String = ""
        var currCodeNameNode: TreeNodeNG2
        progress = 0.75
        for device in devices {
            if(currCodeName != device.codename){
                currCodeNameNode = TreeNodeNG2(name: "\(device.codename)", desc: "CodeName", children: [])
                nodes.append(currCodeNameNode)
                currCodeName = device.codename
            }
            nodes.last?.children?.append(TreeNodeNG2(name: "\(device.buildid)\nRestore RAMDisk exists:\(device.restoreramdiskexists)\nUpdate RAMDisk exists:\(device.updateramdiskexists)", desc: "BuildId"))
        }
        progress = 0.95
        return nodes
    }
    
    func getFirmwaresTree(firmware:DeviceModelNG3) -> [TreeNodeNG2] {
        var nodes: [TreeNodeNG2] = []
        progress = 0.75
        for firmware2 in firmware.firmwares
        {
            nodes.append(TreeNodeNG2(name: "\(firmware2.buildid)\nURL: \(firmware2.url)", desc: "BuildId"))
        }
        progress = 0.95
        return nodes
    }
    
    func mainFetchFunc() async {
        do {
            progressTxt = "Fetching devices ..."
            devicesNG = try await fetchData(apiUrl: "\(BASE_IPSW_API_URL)devices", responseType: [DeviceModelNG2].self)
            print(releases)
        } catch {
            print("Failed to fetch devices: \(error)")
        }
        
        for device in devicesNG{
            devicesIdOptions.append("\(device.identifier)")
        }
        
        do {
            progressTxt = "Fetching device (single) ..."
            devices = try await fetchData(apiUrl: "\(BASE_IPSW_API_URL)keys/device/iPhone3,1", responseType: [DeviceModel].self)
            print(releases)
        } catch {
            print("Failed to fetch device: \(error)")
        }
        
        do {
            progressTxt = "Fetching firmwares ..."
            firmwaresData = try await fetchData(apiUrl: "\(BASE_IPSW_API_URL)device/iPhone8,1?type=ipsw", responseType: DeviceModelNG3.self)
            print(releases)
        } catch {
            print("Failed to fetch firmwares: \(error)")
        }

        do {
            progressTxt = "Fetching releases ..."
            releases = try await fetchData(apiUrl: "\(BASE_IPSW_API_URL)releases", responseType: [ReleaseDateModel].self)
            print(releases)
        } catch {
            print("Failed to fetch releases: \(error)")
        }
        treeRoot.children = getStruct(devices: devices)
        treeData.append(treeRoot)
        progressTxt = "Fetching done!"
        progress = 1.0
    }
}
