//
//  ValidationResult.swift
//  iOS_Task
//
//  Created by sathish on 20/12/21.
//

import Foundation

struct LoginValidation {

    func Validate(loginRequest: LoginRequest) -> ValidationResult
    {
        if(loginRequest.userEmail!.isEmpty)
        {
            return ValidationResult(success: false, error: "User email is empty")
        }

        if(loginRequest.userPassword!.isEmpty)
        {
            return ValidationResult(success: false, error: "User password is empty")
        }

        return ValidationResult(success: true, error: nil)
    }

}

struct LoginRequest : Encodable
{
    var userEmail, userPassword: String?
}
