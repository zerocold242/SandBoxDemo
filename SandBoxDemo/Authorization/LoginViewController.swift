//
//  LoginViewController.swift
//  SandBoxDemo
//
//  Created by Aleksey Lexx on 15.02.2023.
//

import UIKit

enum LoginModel {
    case signUp
    case logIn
    case changePassword
}

class LoginViewController: UIViewController {
    
    private var authMode: LoginModel
    private var firstPass: String?//первый ввод пароля
    private var secondPass: String?//подтверждение пароля
    
    init(authMode: LoginModel) {
        self.authMode = authMode
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var indicatorActivity: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    private lazy var passTextField: CustomTextField = {
        let passTextField = CustomTextField(font: .systemFont(ofSize: 16),
                                            textColor: .black,
                                            backgroundColor: .systemGray5,
                                            placeholder: "   EnterPassword")
        passTextField.isSecureTextEntry = true
        return passTextField
    }()
    
    private lazy var loginButton: CustomButton = {
        let button = CustomButton(title: nil, titleColor: .white, actionTap: { [weak self] in
            
            switch self?.authMode {
            case .signUp:
                self?.signUp()
            case .logIn:
                self?.logIn()
            case .changePassword:
                self?.signUp()
            case .none:
                break
            }
        })
        return button
    }()
    
    private lazy var logoView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "person.circle.fill")
        imageView.alpha = 0.7
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    
    private func loginButtonTitle() {
        switch self.authMode {
        case .signUp:
            self.loginButton.setTitle("Create password", for: .normal)
        case .logIn:
            self.loginButton.setTitle("Enter password", for: .normal)
        case .changePassword:
            self.loginButton.setTitle("Save new password", for: .normal)
            self.isModalInPresentation = true
        }
    }
    
    //метод перехода в документы через координатор
    private func presentDocuments() {
        view.window?.rootViewController = DocumentsCoordinator.shared.createTabBarController()
        view.window?.makeKeyAndVisible()
    }
    
    private func setUpView() {
        view.backgroundColor = .white
        view.addSubview(passTextField)
        view.addSubview(loginButton)
        view.addSubview(logoView)
        view.addSubview(indicatorActivity)
        
        NSLayoutConstraint.activate([
            
            indicatorActivity.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 90),
            indicatorActivity.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            passTextField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            passTextField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            passTextField.heightAnchor.constraint(equalToConstant: 50),
            passTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 180),
            
            loginButton.heightAnchor.constraint(equalToConstant: 50),
            loginButton.topAnchor.constraint(equalTo: passTextField.bottomAnchor, constant: 16),
            loginButton.leadingAnchor.constraint(equalTo: passTextField.leadingAnchor),
            loginButton.trailingAnchor.constraint(equalTo: passTextField.trailingAnchor),
            
            logoView.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 75),
            logoView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoView.heightAnchor.constraint(equalToConstant: 200),
            logoView.widthAnchor.constraint(equalToConstant: 200)
        ])
    }
    
    //метод сохранения нового пароля с подтверждением
    @objc private func signUp() {
        guard let password = passTextField.text else { return }
        if !password.isEmpty, password.count >= 4 {
            let pass = UserDefaults.standard.bool(forKey: "Pass")
            //первый ввод пароля
            if pass == false {
                firstPass = passTextField.text
                DispatchQueue.main.async {
                    self.loginButton.setTitle("Confirm Password", for: .normal)
                    self.passTextField.text = ""
                    UserDefaults.standard.set(true, forKey: "Pass")
                }
                print("First password \(String(describing: firstPass))")
                //подтверждение пароля
            } else {
                secondPass = passTextField.text
                print("Second password \(String(describing: secondPass))")
                if firstPass == secondPass {
                    //в случае корректного подтверждения удаляем пароль из UserDefaults и сохраняем в keychain
                    UserDefaults.standard.removeObject(forKey: "Pass")
                    LoginInspector.shared.signUp(password: password) {
                        self.presentDocuments()
                        if (UserDefaults.standard.objectIsForced(forKey: "ChangePass")) == true {
                            self.dismiss(animated: true, completion: {
                                UserDefaults.standard.removeObject(forKey: "ChangePass")})
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        if (UserDefaults.standard.objectIsForced(forKey: "ChangePass")) == true {
                            self.loginButton.setTitle("Save new password", for: .normal)
                            self.passTextField.text = ""
                        }
                    }
                    UserDefaults.standard.removeObject(forKey: "Pass")
                    WarningAlert.defaultAlert.showAlert(showAlertIn: self, message: "Passwords don't match")
                    self.loginButton.setTitle("Save new password", for: .normal)
                    self.passTextField.text = ""
                }
            }
        } else if !password.isEmpty, password.count < 4 {
            WarningAlert.defaultAlert.showAlert(showAlertIn: self, message: "Password must be at least 4 characters")
        } else if password.isEmpty {
            WarningAlert.defaultAlert.showAlert(showAlertIn: self, message: "Enter Password")
        }
    }
    
    @objc private func logIn() {
        if let password = passTextField.text, !password.isEmpty {
            guard let pass = passTextField.text else { return }
            LoginInspector.shared.logIn(password: pass) { [self] result in
                self.indicatorActivity.startAnimating()
                self.indicatorActivity.isHidden = false
                if result {
                    self.presentDocuments()
                    print("LogIn")
                } else {
                    WarningAlert.defaultAlert.showAlert(showAlertIn: self, message: "Wrong Password")
                    self.passTextField.text = ""
                    self.indicatorActivity.stopAnimating()
                    self.indicatorActivity.isHidden = true
                }
            }
        }
    }
    
    @objc private func passwordTextFieldDidChanged() {
        guard let password = passTextField.text else { return }
        loginButton.isEnabled = !password.isEmpty ? true : false
        isModalInPresentation = !password.isEmpty ? true : false
    }
    
    //скрытие клавиатуры по клику
    private func gesture() {
        let gesture = UITapGestureRecognizer()
        gesture.cancelsTouchesInView = false
        gesture.addTarget(self, action: #selector(self.gestureAction))
        self.view.addGestureRecognizer(gesture)
    }
    
    @objc private func gestureAction() {
        self.view.endEditing(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loginButtonTitle()
        setUpView()
        gesture()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        passTextField.text = .none
    }
}
