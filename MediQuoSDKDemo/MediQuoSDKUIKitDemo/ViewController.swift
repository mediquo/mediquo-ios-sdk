//
//  Created by Marc Hidalgo on 19/4/24.
//

import MediQuoSDK
import UIKit
import SwiftUI

class SDKDemoViewController: UIViewController, UITextFieldDelegate {
    
    private var mediquoSDK: MediQuo?
    private let roomIDTextField = UITextField()
    private let appointmentTextField = UITextField()
    private let apiKey = "o6o2UmYyQqztIfPV"
    private let userID = "5ddda90f-ee61-4242-b736-1c2e58cb2e16"
    
    public init() {
        super.init(nibName: nil, bundle: nil)
        fetchData()
    }
    
    func fetchData() {
        Task { @MainActor in
            do {
                self.mediquoSDK = try await MediQuo(environment: .production, apiKey: apiKey, userID: userID)
            } catch {
                showError(message: "Error loading SDK")
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    //MARK: Private
    
    private func setupUI() {
        view = UIView()
        view.backgroundColor = .systemBackground

        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.distribution = .fillEqually
        
        let label = UILabel()
        label.text = "This is a demo app"
        stackView.addArrangedSubview(label)
        
        let buttons = [
            ("Show professional list", #selector(showProfessionalList)),
            ("Show medical history", #selector(showMedicalHistory)),
            ("Show incoming videocall", #selector(showVideoCall)),
            ("Show incoming audiocall", #selector(showAudioCall)),
        ]
        
        for (title, selector) in buttons {
            let button = createButton(title: title, action: selector)
            stackView.addArrangedSubview(button)
        }
        
        configureTextField(appointmentTextField, placeholder: "Enter Appointment ID")
        stackView.addArrangedSubview(appointmentTextField)
        
        let appointmentDetailsButton = createButton(title: "Show appointment details", action: #selector(showAppointmentDetails))
        stackView.addArrangedSubview(appointmentDetailsButton)
               
        configureTextField(roomIDTextField, placeholder: "Enter Room ID")
        stackView.addArrangedSubview(roomIDTextField)
        
        let chatButton = createButton(title: "Show chat", action: #selector(showChat))
        stackView.addArrangedSubview(chatButton)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }
    
    @objc private func showProfessionalList() {
        guard let mediquoSDK else {
            showError(message: "Error loading SDK")
            return
        }
        let vc = UIHostingController(rootView: mediquoSDK.getSDKView(for: .professionalList))
        presentFullScreenViewController(vc)
    }
    
    @objc private func showMedicalHistory() {
        guard let mediquoSDK else {
            showError(message: "Error loading SDK")
            return
        }
        let vc = UIHostingController(rootView: mediquoSDK.getSDKView(for: .medicalHistory))
        presentFullScreenViewController(vc)
    }
    
    @objc private func showVideoCall() {
        guard let mediquoSDK else {
            showError(message: "Error loading SDK")
            return
        }
        let viewModel = MediQuo.CallViewModel.videoMock
        let vc = UIHostingController(rootView: mediquoSDK.getSDKView(for: .call(callViewModel: viewModel, closeHandler: {})))
        presentFullScreenViewController(vc)
    }
    
    @objc private func showAudioCall() {
        guard let mediquoSDK else {
            showError(message: "Error loading SDK")
            return
        }
        let viewModel = MediQuo.CallViewModel.audioMock
        let vc = UIHostingController(rootView: mediquoSDK.getSDKView(for: .call(callViewModel: viewModel, closeHandler: {})))
        presentFullScreenViewController(vc)
    }
    
    @objc private func showAppointmentDetails() {
        guard let mediquoSDK else {
            showError(message: "Error loading SDK")
            return
        }
        guard let appointmentID = appointmentTextField.text, appointmentID != "" else {
            showError(message: "Please provide a valid ID")
            return
        }
        let vc = UIHostingController(rootView: mediquoSDK.getSDKView(for: .appointmentsDetails(appointmentID: appointmentID, delegate: nil)))
        presentFullScreenViewController(vc)
    }
    
    @objc private func showChat() {
        guard let mediquoSDK else {
            showError(message: "Error loading SDK")
            return
        }
        guard let roomID = Int(roomIDTextField.text ?? "") else {
            showError(message: "Please provide a valid room ID")
            return
        }
        let vc = UIHostingController(rootView: mediquoSDK.getSDKView(for: .chat(roomID: roomID)))
        presentFullScreenViewController(vc)
    }
    
    private func createButton(title: String, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.backgroundColor = UIColor.secondarySystemBackground
        button.setTitleColor(UIColor.label, for: .normal)
        button.layer.cornerRadius = 10
        button.contentHorizontalAlignment = .center
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }

    private func configureTextField(_ textField: UITextField, placeholder: String) {
        textField.placeholder = placeholder
        textField.borderStyle = .roundedRect
    }
    
    private func presentFullScreenViewController(_ viewController: UIViewController) {
        viewController.modalPresentationStyle = .fullScreen
        present(viewController, animated: true)
    }
    
    private func showError(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
