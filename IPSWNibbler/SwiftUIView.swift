//
//  SwiftUIView.swift
//  IPSWNibbler
//
//  Created by Kim David Hauser on 04.12.2023.

import SwiftUI

struct SwiftUIView: View {
    
    @State var selectedFunctionOption:IPSWAPIFunction = .selectFunction
    @State public var selectedDeviceOption = "- Select DeviceID -"
    @State var devicesIdOptions = ["- Select DeviceID -"]
    
    @State var firmwaresData: DeviceModelNG3?
    @State var devicesNG: [DeviceModelNG2] = []
    @State var devices: [DeviceModel] = []
    
    @State var releases: [ReleaseDateModel] = []
    @State var treeData: [TreeNodeNG2] = []
    @State var treeRoot = TreeNodeNG2(name: "iPhone3,1", desc: "Identifier", children: [])
    
    @State public var progress: Double = 0.0
    @State public var progressTxt: String = "Ready..."
    @State public var identifier: String = "12AD87"
    @State public var showText = false
    @State public var showModel = false
    
    var body: some View {
        
        functionSection
        
        if showModel {
            identifierSection
        }
        
        if showText {
            devicesSection
        }
        
        treeSection
        .task {
            await mainFetchFunc()
        }
        
        footerSection
    }
}

#Preview {
    SwiftUIView()
}
