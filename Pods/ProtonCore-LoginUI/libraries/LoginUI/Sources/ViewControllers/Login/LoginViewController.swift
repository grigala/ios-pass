//
//  LoginViewController.swift
//  ProtonCore-Login - Created on 03/11/2020.
//
//  Copyright (c) 2022 Proton Technologies AG
//
//  This file is part of Proton Technologies AG and ProtonCore.
//
//  ProtonCore is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  ProtonCore is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with ProtonCore.  If not, see <https://www.gnu.org/licenses/>.

import UIKit
import ProtonCore_CoreTranslation
import ProtonCore_Login
import ProtonCore_Foundations
import ProtonCore_UIFoundations
import ProtonCore_FeatureSwitch

protocol LoginStepsDelegate: AnyObject {
    func requestTwoFactorCode(username: String, password: String)
    func mailboxPasswordNeeded()
    func createAddressNeeded(data: CreateAddressData, defaultUsername: String?)
    func userAccountSetupNeeded()
    func firstPasswordChangeNeeded()
    func learnMoreAboutExternalAccountsNotSupported()
}

protocol LoginViewControllerDelegate: LoginStepsDelegate {
    func userDidDismissLoginViewController()
    func userDidRequestSignup()
    func userDidRequestHelp()
    func loginViewControllerDidFinish(endLoading: @escaping () -> Void, data: LoginData)
}

final class LoginViewController: UIViewController, AccessibleView, Focusable {

    // MARK: - Outlets

    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var loginTextField: PMTextField!
    @IBOutlet private weak var passwordTextField: PMTextField!
    @IBOutlet private weak var signInButton: ProtonButton!
    @IBOutlet private weak var signUpButton: ProtonButton!
    @IBOutlet private weak var subtitleLabel: UILabel!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var brandImage: UIImageView!
    @IBOutlet weak var signInWithSSOButton: ProtonButton!
    
    // MARK: - Properties

    weak var delegate: LoginViewControllerDelegate?
    var initialError: LoginError?
    var showCloseButton = true
    var isSignupAvailable = true

    var viewModel: LoginViewModel!
    var customErrorPresenter: LoginErrorPresenter?
    var initialUsername: String?
    var onDohTroubleshooting: () -> Void = { }

    var focusNoMore: Bool = false
    private let navigationBarAdjuster = NavigationBarAdjustingScrollViewDelegate()
    private var isSSOEnabled: Bool {
        FeatureFactory.shared.isEnabled(.ssoSignIn) && viewModel.clientApp == .vpn
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle { darkModeAwarePreferredStatusBarStyle() }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupBinding()
        setupDelegates()
        setupNotifications()
        setupGestures()
        setUpHelpButton(action: #selector(needHelpPressed))
        requestDomain()
        if let error = initialError {
            if self.customErrorPresenter?.willPresentError(error: error, from: self) == true { } else { showError(error: error) }
        }
        
        focusOnce(view: loginTextField, delay: .milliseconds(750))
        
        showCloseButton = showCloseButton || isSSOEnabled
        
        setUpCloseButton(showCloseButton: showCloseButton, action: #selector(closePressed))

        generateAccessibilityIdentifiers()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        navigationBarAdjuster.setUp(for: scrollView, shouldAdjustNavigationBar: showCloseButton, parent: parent)
        scrollView.adjust(forKeyboardVisibilityNotification: nil)
    }

    // MARK: - Setup

    private func setupUI() {
        
        brandImage.image = IconProvider.masterBrandGlyph
        brandImage.isHidden = false
        titleLabel.text = viewModel.titleLabel
        titleLabel.textColor = ColorProvider.TextNorm
        subtitleLabel.text = viewModel.subtitleLabel
        subtitleLabel.textColor = ColorProvider.TextWeak
        titleLabel.font = .adjustedFont(forTextStyle: .title2, weight: .bold)
        subtitleLabel.font = .adjustedFont(forTextStyle: .subheadline)
        loginTextField.title = viewModel.loginTextFieldTitle
        passwordTextField.title = viewModel.passwordTextFieldTitle

        view.backgroundColor = ColorProvider.BackgroundNorm
        
        signInButton.setTitle(viewModel.signInButtonTitle, for: .normal)
        signInButton.addTarget(self, action: #selector(signInPressed), for: .touchUpInside)
        
        signUpButton.setMode(mode: .text)
        signUpButton.addTarget(self, action: #selector(signUpPressed), for: .touchUpInside)
        signUpButton.isHidden = !isSignupAvailable || isSSOEnabled
        signUpButton.setTitle(viewModel.signUpButtonTitle, for: .normal)

        loginTextField.autocorrectionType = .no
        loginTextField.autocapitalizationType = .none
        loginTextField.textContentType = .username
        loginTextField.keyboardType = .emailAddress
        loginTextField.returnKeyType = .next

        passwordTextField.autocorrectionType = .no
        passwordTextField.autocapitalizationType = .none
        passwordTextField.textContentType = .password

        loginTextField.value = initialUsername ?? ""
        
        signInWithSSOButton.isHidden = !isSSOEnabled
        signInWithSSOButton.setTitle(viewModel.signInWithSSOButtonTitle, for: .normal)
        signInWithSSOButton.setMode(mode: .text)
        signInWithSSOButton.addTarget(self, action: #selector(signInWithSSO), for: .touchUpInside)
    }

    private func requestDomain() {
        viewModel.updateAvailableDomain()
    }

    private func setupGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard (_:)))
        self.view.addGestureRecognizer(tapGesture)
    }
    
    func setUpHelpButton(action: Selector) {
        let helpButton = UIBarButtonItem(title: CoreString._hv_help_button, style: .plain, target: self, action: action)
        helpButton.tintColor = ColorProvider.InteractionNorm
        navigationItem.setHidesBackButton(true, animated: false)
        navigationItem.setRightBarButton(helpButton, animated: true)
        navigationItem.assignNavItemIndentifiers()
    }

    private func setupDelegates() {
        loginTextField.delegate = self
        passwordTextField.delegate = self
    }

    private func setupBinding() {
        viewModel.error.bind { [weak self] error in
            guard let self = self else {
                return
            }

            switch error {
            case .invalidCredentials:
                self.setError(textField: self.passwordTextField, error: nil)
                self.setError(textField: self.loginTextField, error: nil)
                if self.customErrorPresenter?.willPresentError(error: error, from: self) == true { } else { self.showError(error: error) }
            default:
                if self.customErrorPresenter?.willPresentError(error: error, from: self) == true { } else { self.showError(error: error) }
            }
        }
        viewModel.finished.bind { [weak self] result in
            switch result {
            case let .done(data):
                self?.delegate?.loginViewControllerDidFinish(endLoading: { [weak self] in self?.viewModel.isLoading.value = false }, data: data)
            case .twoFactorCodeNeeded:
                guard
                    let username = self?.loginTextField.value,
                    let password = self?.passwordTextField.value
                else { return }
                // Clean username and password before leaving this page
                // To eliminate KeyChain auto remember prompt
                self?.clearAccount()
                self?.delegate?.requestTwoFactorCode(username: username, password: password)
            case .mailboxPasswordNeeded:
                self?.delegate?.mailboxPasswordNeeded()
            case let .createAddressNeeded(data, defaultUsername):
                self?.delegate?.createAddressNeeded(data: data, defaultUsername: defaultUsername)
            }
        }
        viewModel.isLoading.bind { [weak self] isLoading in
            self?.view.isUserInteractionEnabled = !isLoading
            self?.signInButton.isSelected = isLoading
        }
        try? self.loginTextField.setUpChallenge(viewModel.challenge, type: .username)

        NotificationCenter.default
            .addObserver(self,
                         selector: #selector(preferredContentSizeChanged(_:)),
                         name: UIContentSizeCategory.didChangeNotification,
                         object: nil)
    }

    // MARK: - Actions
    
    @objc private func signInWithSSO() {
        viewModel.isSSOEnabled = true
        signInWithSSOButton.isHidden = viewModel.isSSOEnabled
        passwordTextField.isHidden = viewModel.isSSOEnabled
        loginTextField.title = viewModel.loginTextFieldTitle
        titleLabel.text = viewModel.titleLabel
        signUpButton.setTitle(viewModel.signUpButtonTitle, for: .normal)
        signUpButton.removeTarget(self, action: #selector(signUpPressed), for: .touchUpInside)
        signUpButton.addTarget(self, action: #selector(signInWithEmail), for: .touchUpInside)
    }
    
    @objc private func signInWithEmail() {
        viewModel.isSSOEnabled = false
        signInWithSSOButton.isHidden = viewModel.isSSOEnabled
        passwordTextField.isHidden = viewModel.isSSOEnabled
        loginTextField.title = viewModel.loginTextFieldTitle
        titleLabel.text = viewModel.titleLabel
        signUpButton.setTitle(viewModel.signUpButtonTitle, for: .normal)
        signUpButton.removeTarget(self, action: #selector(signInWithEmail), for: .touchUpInside)
        signUpButton.addTarget(self, action: #selector(signUpPressed), for: .touchUpInside)
    }
    
    @objc private func signInPressed(_ sender: Any) {
        cancelFocus()
        dismissKeyboard()

        let usernameValid = setAddressTextFieldError()
        let passwordValid = validatePassword()

        guard usernameValid, passwordValid else {
            return
        }

        PMBanner.dismissAll(on: self)
        viewModel.login(username: loginTextField.value, password: passwordTextField.value)
    }

    @objc private func signUpPressed(_ sender: ProtonButton) {
        cancelFocus()
        clearAccount()
        delegate?.userDidRequestSignup()
    }

    @objc private func needHelpPressed() {
        cancelFocus()
        delegate?.userDidRequestHelp()
    }

    @objc private func closePressed(_ sender: Any) {
        cancelFocus()
        delegate?.userDidDismissLoginViewController()
    }

    @objc func dismissKeyboard(_ sender: UITapGestureRecognizer) {
        dismissKeyboard()
    }

    private func dismissKeyboard() {
        if loginTextField.isFirstResponder {
            _ = loginTextField.resignFirstResponder()
        }

        if passwordTextField.isFirstResponder {
            _ = passwordTextField.resignFirstResponder()
        }
    }

    private func clearAccount() {
        passwordTextField.value = ""
        loginTextField.value = ""
    }

    @objc
    private func preferredContentSizeChanged(_ notification: Notification) {
        guard DFSSetting.enableDFS else { return }
        titleLabel.font = .adjustedFont(forTextStyle: .title2, weight: .bold)
        subtitleLabel.font = .adjustedFont(forTextStyle: .subheadline)
    }

    // MARK: - Keyboard

    private func setupNotifications() {
        NotificationCenter.default
            .setupKeyboardNotifications(target: self, show: #selector(keyboardWillShow), hide: #selector(keyboardWillHide))
    }

    @objc private func keyboardWillShow(notification: NSNotification) {
        adjust(scrollView, notification: notification,
               topView: topView(of: loginTextField, passwordTextField),
               bottomView: signUpButton)
    }

    @objc private func keyboardWillHide(notification: NSNotification) {
        adjust(scrollView, notification: notification, topView: titleLabel, bottomView: signUpButton)
    }

    // MARK: - Validation

    @discardableResult
    private func setAddressTextFieldError() -> Bool {
        let usernameValid = viewModel.validate(username: loginTextField.value)
        switch usernameValid {
        case let .failure(error):
            setError(textField: loginTextField, error: error)
            return false
        case .success:
            clearError(textField: loginTextField)
            return true
        }
    }

    @discardableResult
    private func validatePassword() -> Bool {
        let passwordValid = viewModel.validate(password: passwordTextField.value)
        switch passwordValid {
        case let .failure(error):
            setError(textField: passwordTextField, error: error)
            return false
        case .success:
            clearError(textField: passwordTextField)
            return true
        }
    }
}

// MARK: - Text field delegate

extension LoginViewController: PMTextFieldDelegate {

    func didChangeValue(_ textField: PMTextField, value: String) {}

    func textFieldShouldReturn(_ textField: PMTextField) -> Bool {
        if textField == loginTextField {
            _ = passwordTextField.becomeFirstResponder()
        } else {
            _ = textField.resignFirstResponder()
        }
        return true
    }

    func didBeginEditing(textField: PMTextField) {}

    func didEndEditing(textField: PMTextField) {
        switch textField {
        case loginTextField:
            setAddressTextFieldError()
        case passwordTextField:
            validatePassword()
        default:
            break
        }
    }
}

// MARK: - Additional errors handling

extension LoginViewController: LoginErrorCapable {
    
    func onUserAccountSetupNeeded() {
        delegate?.userAccountSetupNeeded()
    }

    func onFirstPasswordChangeNeeded() {
        delegate?.firstPasswordChangeNeeded()
    }
    
    func onLearnMoreAboutExternalAccountsNotSupported() {
        delegate?.learnMoreAboutExternalAccountsNotSupported()
    }

    var bannerPosition: PMBannerPosition { .top }
}
