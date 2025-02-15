//
//  AuthenticationController.swift
//  BetterProfessorApp
//
//  Created by Cody Morley on 4/29/20.
//  Copyright © 2020 Lambda. All rights reserved.
//

import Foundation
import UIKit

class AuthenticationController {
    // MARK: - Enums & Type Aliases 
    enum HTTPMethod: String {
        case get = "GET"
        case post = "POST"
        case put = "PUT"
        case delete = "DELETE"
    }
    enum NetworkError: Error {
        case failedRegister
        case failedLogIn
        case noData
        case noEncode
        case noDecode
        case badResponse
    }
    // MARK: - Properties
    private var baseURL = URL(string: "https://better-professor-karavil.herokuapp.com/auth")!
    private lazy var registerURL = baseURL.appendingPathComponent("/register/")
    private lazy var loginURL = baseURL.appendingPathComponent("/login/")
    private lazy var jsonEncoder = JSONEncoder()
    private lazy var jsonDecoder = JSONDecoder()
    static var id: Int?
    static var authToken: Token?
    static let shared = AuthenticationController()
    var auth: Token? = AuthenticationController.authToken
    // MARK: - Network Functions
    func register(with credentials: UserCredentials, completion: @escaping (Result<Bool, NetworkError>) -> Void) {
        var request = postRequest(for: registerURL)
        do {
            let jsonData = try jsonEncoder.encode(credentials)
            request.httpBody = jsonData
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    NSLog("Error - failed to register new user: \(error) \(error.localizedDescription)")
                    completion(.failure(.failedRegister))
                    return
                }
                guard let response = response as? HTTPURLResponse else {
                        NSLog("Error - Bad Response. Registration Unsucessful: " +
                            "\(String(describing: error)) \(String(describing: error?.localizedDescription))")
                        return completion(.failure(.badResponse))
                }
                guard let data = data else {
                    NSLog("Error - No data recieved")
                    return completion(.failure(.noData))
                }
                print(String(data: data, encoding: .utf8) as Any)
                do {
                    let id = try? self.jsonDecoder.decode(ProfessorID.self,
                                                          from: data)
                    completion(.success(true))
                    print(data)
                }
            }.resume()
        } catch {
            NSLog("Error - Error encoding user credentials. \(error) \(error.localizedDescription)")
            return completion(.failure(.noEncode))
        }
    }
    func login(login: Login, completion: @escaping (Result<Bool, NetworkError>) -> Void) {
        var request = postRequest(for: loginURL)
        do {
            let jsonData = try jsonEncoder.encode(login)
            request.httpBody = jsonData
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    NSLog("Error - Not logged in: \(error) \(error.localizedDescription)")
                    completion(.failure(.failedLogIn))
                    return
                }
                guard (response as? HTTPURLResponse) != nil
                    else {
                        NSLog("Error - Sign in was unsuccessful, bad response. \(String(describing: error))")
                        completion(.failure(.failedLogIn))
                        return
                }
                guard let data = data else {
                    NSLog("Error - Sign in unsuccessful, no data recieved. \(String(describing: error))")
                    completion(.failure(.badResponse))
                    return
                }
                do {
                    AuthenticationController.authToken = try self.jsonDecoder.decode(Token.self, from: data)
                    print("\(String(describing: AuthenticationController.authToken))" + "In URLSession")
                    print(AuthenticationController.authToken as Any)
                    completion(.success(true))
                } catch {
                    NSLog("Error - Sign in unsuccessful. Error Decoding token. \(error)")
                    completion(.failure(.noDecode))
                }
            }.resume()
        } catch {
            NSLog("Error - Sign in unsuccessful. Error encoding user info to database. \(error)")
            completion(.failure(.noEncode))
        }
    }
    // MARK: - Helper Functions
    private func postRequest(for url: URL) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.post.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        return request
    }
}
