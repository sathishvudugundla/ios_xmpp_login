//
//  LoginViewModel.swift
//  iOS_Task
//
//  Created by sathish on 20/12/21.
//

import Foundation

protocol LoginViewModelDelegate {
    func didReceiveLoginResponse(isconnected:Bool)
    func Nonetwork(isconnected:Bool)
}

struct LoginViewModel
{
    var delegate : LoginViewModelDelegate?

    func loginUser(loginRequest: LoginRequest)
    {
        let validationResult = LoginValidation().Validate(loginRequest: loginRequest)

        if XmppClient.shared.checketwork()
        {
        if(validationResult.success)
        {
            
             XmppClient.shared.connect(username: loginRequest.userEmail!, userpassword: loginRequest.userPassword!)
        }
        else
        {
            self.delegate?.didReceiveLoginResponse(isconnected: false)
        }
            
        }
        else
        {
            self.delegate?.Nonetwork(isconnected: false)
            
        }
        
    }
}
