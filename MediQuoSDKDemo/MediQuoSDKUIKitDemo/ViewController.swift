
import MediQuoSDK
import UIKit

@available(iOS 17, *)
#Preview {
    SDKDemoViewController()
}

class SDKDemoViewController: UIViewController, UITextFieldDelegate, MediQuoEventDelegate {
    
    private var mediquoSDK: MediQuo?
    private let roomIDTextField = UITextField()
    private let appointmentTextField = UITextField()
    private let apiKey = "xuI6zxyDFR0R4oy8"
    private let userID = "121235435"
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private var callVC: UIViewController?

    override func loadView() {
        let scrollView = UIScrollView()
        scrollView.alwaysBounceVertical = true
        view = scrollView
        view.backgroundColor = .systemBackground

        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.distribution = .fillEqually

        titleLabel.text = "Loading SDK..."
        titleLabel.font = UIFont.systemFont(ofSize: 20)
        stackView.addArrangedSubview(titleLabel)

        subtitleLabel.text = "Socket status: Connecting"
        stackView.addArrangedSubview(subtitleLabel)

        let buttons = [
            ("Show professional list", #selector(showProfessionalList)),
            ("Show medical history", #selector(showMedicalHistory)),
            ("Show incoming video call", #selector(showVideoCall)),
            ("Show incoming audio call", #selector(showAudioCall)),
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
    
    //MARK: MediQuoEventDelegate

    func didChangeSocketStatus(isConnected: Bool, previousIsConnected: Bool) {
        if isConnected {
            self.subtitleLabel.text = "Socket status: Connected"
        } else {
            self.subtitleLabel.text = "Socket status: Connecting"
        }
    }
    
    /// Assume only one call happens at a time
    func didReceiveCall(_ call: MediQuoSDK.MediQuo.CallViewModel) {
        guard let windowScene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
              let visibleVC = windowScene.keyWindow?.visibleViewController,
              let vc = mediquoSDK?.getSDKViewController(for: .call(callViewModel: call)) else {
            return
        }
        vc.modalPresentationStyle = .fullScreen
        visibleVC.present(vc, animated: true)
        self.callVC = vc
    }
    
    func didRejectCall(_ call: MediQuoSDK.MediQuo.CallViewModel.ID) {
        self.callVC?.dismiss(animated: true)
        self.callVC = nil
    }

    //MARK: Private
    
    private func fetchData() {
        Task { @MainActor in
            do {
                self.mediquoSDK = try await MediQuo(apiKey: apiKey, userID: userID)
                self.mediquoSDK?.eventDelegate = self
                self.titleLabel.text = "SDK loaded successfully"
            } catch {
                self.titleLabel.text = "SDK error"
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
            viewController.navigationItem.rightBarButtonItem = .init(image: .init(systemName: "ellipsis"), menu: .init(children: [
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

private extension UIWindow {

    var visibleViewController: UIViewController? {
        return UIWindow.getVisibleViewControllerFrom(self.rootViewController)
    }

    private static func getVisibleViewControllerFrom(_ vc: UIViewController?) -> UIViewController? {
        if let nc = vc as? UINavigationController {
            return UIWindow.getVisibleViewControllerFrom(nc.visibleViewController)
        } else if let tc = vc as? UITabBarController {
            return UIWindow.getVisibleViewControllerFrom(tc.selectedViewController)
        } else {
            if let pvc = vc?.presentedViewController {
                return UIWindow.getVisibleViewControllerFrom(pvc)
            } else {
                return vc
            }
        }
    }
}
