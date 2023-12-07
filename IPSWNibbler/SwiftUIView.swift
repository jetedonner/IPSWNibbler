//
//  SwiftUIView.swift
//  IPSWNibbler
//
//  Created by Kim David Hauser on 04.12.2023.

import SwiftUI

struct SwiftUIView: View {
    
    @State var selectedFunctionOption:IPSWAPIFunction = .selectFunction
    
    @State var functionOption = [
        IPSWAPIFunction.selectFunction,
        IPSWAPIFunction.device,
        IPSWAPIFunction.devices,
        IPSWAPIFunction.devicesOnlyKeys,
        IPSWAPIFunction.firmwares,
        IPSWAPIFunction.downloadIPSW,
        IPSWAPIFunction.IPSWInfo,
        IPSWAPIFunction.IPSWVersion,
        IPSWAPIFunction.downloadITunes,
        IPSWAPIFunction.iTunesPlatform,
        IPSWAPIFunction.keysDeviceList,
        IPSWAPIFunction.keysIPSWList,
        IPSWAPIFunction.model,
        IPSWAPIFunction.otaDoc,
        IPSWAPIFunction.otaDownload,
        IPSWAPIFunction.otaInfo,
        IPSWAPIFunction.otaVersion,
        IPSWAPIFunction.releases
    ]
    
    @State private var selectedDeviceOption = "- Select DeviceID -"
    @State var devicesIdOptions = ["- Select DeviceID -"]
    
    @State var firmwaresData: DeviceModelNG3?
    @State var devicesNG: [DeviceModelNG2] = []
    @State var devices: [DeviceModel] = []
    
    @State var releases: [ReleaseDateModel] = []
    
//    @State var releases: [ReleaseDateModel] = []
    @State var treeData: [TreeNodeNG2] = []
    @State var treeRoot = TreeNodeNG2(name: "iPhone3,1", desc: "Identifier", children: [])
    @State private var progress: Double = 0.0
    @State private var progressTxt: String = "Ready..."
    @State private var identifier: String = "12AD87"
    @State private var showText = false
    @State private var showModel = false
    
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
    
    var body: some View {
        Picker("Function\\:", selection: $selectedFunctionOption) {
            ForEach(functionOption, id: \.self) { option in
                Text(option.stringValue).tag(option)
            }
        }
        .onChange(of: selectedFunctionOption, {
            print("Selected option changed to: \(selectedFunctionOption)")
            
            if(selectedFunctionOption == .firmwares){
                showText = true
                treeRoot.desc = "Firmwares for"
                treeRoot.children = getFirmwaresTree(firmware: firmwaresData!)
            }else if(selectedFunctionOption == .model){
                showModel = true
//                treeRoot.desc = "Firmwares for"
//                treeRoot.children = getFirmwaresTree(firmware: firmwaresData!)
            }else{
                showText = false
                showModel = false
            }
        })
        .padding([.horizontal, .top])
        if showModel {
//            Label("Identifier:")
            HStack{
                LabeledContent {
                    TextField("Enter a identifier...", text: $identifier)
                } label: {
                    Text("Identifier:")
                }
                Button("Get Model") {
                    print("GET MODEL")
                }
            }.padding(.horizontal)
//            TextField("Identifier", text: $identifier)
//                .padding(.horizontal)
//                .labelStyle(.titleOnly)
        }
        
        if showText {
            Picker("Devices\\:", selection: $selectedDeviceOption) {
                ForEach(devicesIdOptions, id: \.self) { option in
                    Text(option)
                }
            }
            .padding([.horizontal, .bottom])
            .onChange(of: selectedDeviceOption, {
                print("Selected option changed to: \(selectedDeviceOption)")
                if(selectedFunctionOption == .firmwares){
                    treeRoot.name = selectedDeviceOption
                    Task.init {
                        do {
                            firmwaresData = try await fetchData(apiUrl: "\(BASE_IPSW_API_URL)\(selectedFunctionOption.url)/iPhone8,1?type=ipsw", responseType: DeviceModelNG3.self)
                            print(releases)
                        } catch {
                            print("Failed to fetch firmwares: \(error)")
                        }
                        treeRoot.children = getFirmwaresTree(firmware: firmwaresData!)
                    }
                }else{
                    showText = false
                }
            })
        }
        
        List {
            OutlineGroup(treeData, children: \.children) { node in
                VStack {
                    Text(node.desc + ": " + node.name).textSelection(.enabled)
//                    Link("Visit OpenAI", destination: URL(string: "https://www.openai.com")!)
////                        .font(.headline)
//                        .foregroundColor(.blue)
//                        .frame(alignment:.leading)
                    
                }
                
            }
        }
        .padding(.horizontal)
        .task {
            
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
//            IPSWAPIFunction.releases.url
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
        HStack{
            Text(progressTxt)
            Spacer()
            ProgressView(value: progress, total: 1.0)
            .onDisappear {
                print("View is disappearing")
                exit(0)
            }
            .frame(width: 200)
        }
        .padding(.horizontal)
        Button("Close") {
            exit(0)
        }
        .padding(.bottom)
    }
}

#Preview {
    SwiftUIView()
}
