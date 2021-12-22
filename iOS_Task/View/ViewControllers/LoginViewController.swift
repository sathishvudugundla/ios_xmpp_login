//
//  LoginViewController.swift
//  iOS_Task
//
//  Created by sathish on 20/12/21.
//

import UIKit
import Toast_Swift
class LoginViewController: UIViewController, XmppConnectDelegate {
    
    func AuthenticationFailed() {
        showToastmessage(message: "Invalid Credentials, Please use valid one", position: .center)
    }
    
    func navigateToNextVc() {
        DispatchQueue.main.async {
            self.showToastmessage(message: "Authentication success", position: .center)
        let vc = ListOfWeatherViewController.getRootController()
            self.showVC(vc: vc)
            
        }
    }
    
    @IBOutlet var userNameObj: UITextField!
    
    @IBOutlet var passwordObj: UITextField!
    private var loginViewModel = LoginViewModel()
    override func viewDidLoad() {
        super.viewDidLoad()

        loginViewModel.delegate = self
        XmppClient.shared.XmppConnectDelegateObj = self
    }
    
    @IBAction func LoginAction(_ sender: UIButton) {
        
        let request = LoginRequest(userEmail: userNameObj.text, userPassword: passwordObj.text)
        loginViewModel.loginUser(loginRequest: request)
    }
    
    func showToastmessage(message : String, position : ToastPosition) {
        var style = ToastStyle()
        style.messageColor = .white
        style.backgroundColor = .lightGray
        self.view.makeToast(message, duration: 2, position: position, title: "", image: nil, style: style) { (isFinished) in
        }
    }
}

extension LoginViewController : LoginViewModelDelegate
{
    func Nonetwork(isconnected: Bool) {
        if !isconnected
        {
            self.showToastmessage(message: "Please check your network", position: .center)
        }
    }
    
    func didReceiveLoginResponse(isconnected:Bool)
    {
        if !isconnected
        {
            self.showToastmessage(message: "Input fields can not be emty", position: .center)
        }
    }
    func showVC(vc: UIViewController) {
        if let nv = self.navigationController {
            
            nv.pushViewController(vc, animated: true)
        }else{
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true)
        }
    }
}
