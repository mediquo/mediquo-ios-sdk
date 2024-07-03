
import MediQuoSDK
import UIKit

@available(iOS 17, *)
#Preview {
    SDKDemoViewController()
}

class SDKDemoViewController: UIViewController, UITextFieldDelegate {
    
    private var mediquoSDK: MediQuo?
    private let roomIDTextField = UITextField()
    private let appointmentTextField = UITextField()
    private let apiKey = "o6o2UmYyQqztIfPV"
    private let userID = "5ddda90f-ee61-4242-b736-1c2e58cb2e16"

    override func loadView() {
        let scrollView = UIScrollView()
        scrollView.alwaysBounceVertical = true
        view = scrollView
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
        
        stackView.layoutMargins = .init(top: 20, left: 20, bottom: 20, right: 20)
        stackView.isLayoutMarginsRelativeArrangement = true
        view.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            stackView.widthAnchor.constraint(equalTo: view.widthAnchor)
        ])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchData()
    }
    
    //MARK: Private
    
    private func fetchData() {
        Task { @MainActor in
            do {
                self.mediquoSDK = try await MediQuo(apiKey: apiKey, userID: userID)
            } catch {
                showError(message: "Error loading SDK")
            }
        }
    }
    
    @objc private func showProfessionalList() {
        presentFullScreenViewController(.professionalList)
    }
    
    @objc private func showMedicalHistory() {
        presentFullScreenViewController(.medicalHistory)
    }
    
    @objc private func showVideoCall() {
        let viewModel = MediQuo.CallViewModel.videoMock
        presentFullScreenViewController(.call(callViewModel: viewModel, closeHandler: {}))
    }
    
    @objc private func showAudioCall() {
        let viewModel = MediQuo.CallViewModel.audioMock
        presentFullScreenViewController(.call(callViewModel: viewModel, closeHandler: {}))
    }
    
    @objc private func showAppointmentDetails() {
        guard let appointmentID = appointmentTextField.text, appointmentID != "" else {
            showError(message: "Please provide a valid ID")
            return
        }
        presentFullScreenViewController(.appointmentsDetails(appointmentID: appointmentID, delegate: nil))
    }
    
    @objc private func showChat() {
        guard let roomID = Int(roomIDTextField.text ?? "") else {
            showError(message: "Please provide a valid room ID")
            return
        }
        presentFullScreenViewController(.chat(roomID: roomID))
    }
    
    private func createButton(title: String, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.backgroundColor = UIColor.accent
        button.setTitleColor(UIColor.label, for: .normal)
        button.layer.cornerRadius = 10
        button.contentHorizontalAlignment = .center
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: action, for: .touchUpInside)
        button.heightAnchor.constraint(greaterThanOrEqualToConstant: 50).isActive = true
        return button
    }

    private func configureTextField(_ textField: UITextField, placeholder: String) {
        textField.placeholder = placeholder
        textField.borderStyle = .roundedRect
    }
    
    private func actionFor(title: String, imageName: String, navigationController: UINavigationController, viewKind: MediQuo.ViewKind) -> UIAction {
        return UIAction(title: title, image: UIImage(systemName: imageName)) { [weak self, navigationController] (_) in
            guard let mediquoSDK = self?.mediquoSDK else {
                return
            }
            navigationController.pushViewController(mediquoSDK.getSDKViewController(for: viewKind, embedInNavigationController: false), animated: true)
        }
    }

    private func presentFullScreenViewController(_ viewKind: MediQuo.ViewKind) {
        guard let mediquoSDK else {
            showError(message: "Error loading SDK")
            return
        }
        let viewController = mediquoSDK.getSDKViewController(for: viewKind, embedInNavigationController: false)
        let navigationController = UINavigationController(rootViewController: viewController)
        switch viewKind {
        case .professionalList:
            viewController.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "ellipsis"), menu: .init(children: [
                actionFor(title: "Alérgias", imageName: "allergens", navigationController: navigationController, viewKind: .allergies),
                actionFor(title: "Medicaciones", imageName: "pill", navigationController: navigationController, viewKind: .medication),
                actionFor(title: "Informes", imageName: "newspaper", navigationController: navigationController, viewKind: .medicalReport),
                actionFor(title: "Recetas", imageName: "rectangle.and.pencil.and.ellipsis", navigationController: navigationController, viewKind: .prescription),
            ]))
        default:
            break
        }
        viewController.navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: .init(systemName: "xmark"),
            style: .plain,
            target: self,
            action: #selector(dismissMediquoViewController)
        )
        navigationController.modalPresentationStyle = .fullScreen
        present(navigationController, animated: true)
    }
    
    private func showError(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    @objc
    private func dismissMediquoViewController() {
        dismiss(animated: true, completion: nil)
    }
}
