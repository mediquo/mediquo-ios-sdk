//
//  Created by Marc Hidalgo on 30/1/24.
//

import SwiftUI
import MediQuoSDK

@main
struct SDKDemoApp: App {
    
    var body: some Scene {
        WindowGroup {
            ContentView.Async()
        }
    }
}

struct ContentView: View {
    
    init(mediquoSDK: MediQuo) {
        self.mediquoSDK = mediquoSDK
    }
    
    private let mediquoSDK: MediQuo
    
    @State
    private var showFullScreenCover: FullScreenCoverType?
    
    @State
    private var appointmentID: String = ""
    
    @State
    private var roomID: String = ""
    
    @Environment(\.dismiss)
    private var dismiss

    enum FullScreenCoverType: Identifiable {
        case professionalList
        case medicalHistory
        case videoCall
        case audioCall
        case chat
        case appointmentDetails
        
        var id: Int {
            hashValue
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Text("This is a demo app")
                Spacer()
                Button {
                    self.showFullScreenCover = .professionalList
                } label: {
                    Text("Show professional list")
                        .frame(maxWidth: .infinity)
                }
                
                Button {
                    self.showFullScreenCover = .medicalHistory
                } label: {
                    Text("Show medical history")
                        .frame(maxWidth: .infinity)
                }
                
                Button {
                    self.showFullScreenCover = .videoCall
                } label: {
                    Text("Show incoming videocall")
                        .frame(maxWidth: .infinity)
                }
                
                Button {
                    self.showFullScreenCover = .audioCall
                } label: {
                    Text("Show incoming audiocall")
                        .frame(maxWidth: .infinity)
                }
                
                VStack {
                    TextField("Appointment ID", text: $appointmentID)
                        .textFieldStyle(.roundedBorder)
                    Button {
                        self.showFullScreenCover = .appointmentDetails
                    } label: {
                        Text("Show appointment details")
                            .frame(maxWidth: .infinity)
                    }
                    
                }
                VStack {
                    TextField("Room ID", text: $roomID)
                        .textFieldStyle(.roundedBorder)
                    Button {
                        self.showFullScreenCover = .chat
                    } label: {
                        Text("Show chat")
                            .frame(maxWidth: .infinity)
                    }
                }
                Spacer()
            }
            .padding(40)
            .font(.title3)
            .buttonStyle(.borderedProminent)
            .navigationTitle("Demo app")
            .navigationBarTitleDisplayMode(.inline)
            .fullScreenCover(item: $showFullScreenCover) { type in
                switch type {
                case .professionalList:
                    mediquoSDK.getSDKView(for: .professionalList)
                case .medicalHistory:
                    mediquoSDK.getSDKView(for: .medicalHistory)
                case .videoCall:
                    mediquoSDK.getSDKView(for: .call(callViewModel: .init(id: "", roomID: 0, sessionID: "", tokenID: "", type: .video, professional: .init(id: "0", name: "")), closeHandler: { }))
                case .audioCall:
                    mediquoSDK.getSDKView(for: .call(callViewModel: .init(id: "", roomID: 0, sessionID: "", tokenID: "", type: .video, professional: .init(id: "0", name: "")), closeHandler: { }))
                case .appointmentDetails:
                    if appointmentID == "" {
                        SDKErrorView(message: "Please provide a valid ID")
                    } else {
                        mediquoSDK.getSDKView(for: .appointmentsDetails(appointmentID: appointmentID, delegate: nil))
                    }
                case .chat:
                    if roomID != "", let id = Int(roomID) {
                        mediquoSDK.getSDKView(for: .chat(roomID: id))
                    } else {
                        SDKErrorView(message: "Please provide a valid room ID")
                    }
                }
            }
        }
        /// Push notification call example
        /*.task {
            try? await
            mediquoSDK.pushNotification(Data(), type: .appleAPNS)
        }*/
    }
    
    struct Async: View {
        let userID = "90454859-89d9-4730-8096-4d032ca7ac61"
        let apiKey = "xuI6zxyDFR0R4oy8"

        enum LoadingPhase {
            case loading
            case loaded(MediQuo)
        }
        
        @State var state: LoadingPhase = .loading
        
        public var body: some View {
            VStack {
                switch state {
                case .loading:
                    ProgressView()
                case .loaded(let mediQuoSDK):
                    ContentView(mediquoSDK: mediQuoSDK)
                }
            }.task {
                let mediquoSDK = try! await MediQuo(environment: .production, apiKey: apiKey, userID: userID)
                self.state = .loaded(mediquoSDK)
            }
        }
    }
}

struct SDKErrorView: View {
    
    let message: String
    
    @Environment(\.dismiss)
    private var dismiss
    
    var body: some View {
        NavigationView {
            Text(message)
                .navigationTitle("Error")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar() {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark")
                                .foregroundStyle(Color.accentColor)
                        }
                    }
                }
        }
    }
}
