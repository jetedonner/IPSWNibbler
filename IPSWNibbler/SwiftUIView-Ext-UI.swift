//
//  SwiftUIView-Extension.swift
//  IPSWNibbler
//
//  Created by Kim David Hauser on 07.12.2023.
//

import SwiftUI

extension SwiftUIView{
    public var functionSection: some View {
        Section() {
            Picker("Function\\:", selection: $selectedFunctionOption) {
                ForEach(IPSWAPIFunction.allCases, id: \.self) { option in
                    Text(option.stringValue).tag(option)
                }
            }
            .onChange(of: selectedFunctionOption, {
                print("Selected option changed to: \(selectedFunctionOption)")
                
                if(selectedFunctionOption == .firmwares){
                    showText = true
                    showModel = false
                    treeRoot.desc = "Firmwares for"
                    treeRoot.children = getFirmwaresTree(firmware: firmwaresData!)
                }else if(selectedFunctionOption == .model){
                    showModel = true
                    showText = false
                }else{
                    showText = false
                    showModel = false
                }
            })
            .padding([.horizontal, .top])
        }
    }
    
    public var identifierSection: some View {
        Section() {
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
        }
    }
    
    public var devicesSection: some View {
        Section() {
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
                            treeRoot.children = getFirmwaresTree(firmware: firmwaresData!)
                        } catch {
                            print("Failed to fetch firmwares: \(error)")
                        }
                    }
                }else{
                    showText = false
                }
            })
        }
    }
    
    public var treeSection: some View {
        Section() {
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
        }
    }
    
    public var footerSection: some View {
        Section() {
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
}
