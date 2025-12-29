
import AuthenticationServices
import SwiftUI

struct SignInWithAppleDemo: View {
    @State private var authorizationResult: ASAuthorization? = nil
    @State private var error: Error? = nil

    var body: some View {

        NavigationStack {
            VStack(spacing: 48) {

                SignInWithAppleButton(
                    .signIn,
                    onRequest: { request in
                        // this will have no effect
                        // request.requestedScopes = [.fullName, .email]
                    },
                    onCompletion: { result in
                        switch result {
                        case .success(let authResult):
                            self.error = nil
                            self.authorizationResult = authResult
                        case .failure(let error):
                            self.error = error
                            self.authorizationResult = nil

                        }
                    }
                )
                .signInWithAppleButtonStyle(.black)
                // otherwise will take all available spaces
                .fixedSize()

                if let error {
                    Text(error.localizedDescription)
                        .foregroundStyle(.red)
                }

                if let authorizationResult {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Provider: \(authorizationResult.provider.title)")

                        switch authorizationResult.credential {

                        case let appleIDCredential
                            as ASAuthorizationAppleIDCredential:

                            // Create an account in your system.
                            let userIdentifier = appleIDCredential.user
                            let fullName = appleIDCredential.fullName
                            let email = appleIDCredential.email

                            Text(
                                "User ID: \(userIdentifier, default: "(Unknown)")"
                            )
                            Text("Name: \(fullName, default: "(Unknown)")")
                            Text("Email: \(email, default: "(Unknown)")")

                        default:
                            Text("Some Other credentials")
                        }

                    }

                }

            }
            .padding()
            .padding(.top, 48)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background(.yellow.opacity(0.1))
            .navigationTitle("SignIn With Apple")
            .task {
                // to check whether the user is already signed in or not
                do {
                    let result = try await ASAuthorizationAppleIDProvider()
                        .credentialState(
                            forUserID: "appleIDCredential.user we get above"
                        )
                    switch result {

                    case .revoked:
                        print("revoked")
                    case .authorized:
                        print("authorized")
                    case .notFound:
                        print("not found")
                    case .transferred:
                        print("transferred")
                    @unknown default:
                        print("unknown")
                    }
                } catch (let error) {
                    print(error)
                }
            }
        }

    }
}

extension ASAuthorizationProvider {
    var title: String {
        switch self {
        case _ as ASAuthorizationAccountCreationProvider:
            "AccountCreation"
        case _ as ASAuthorizationAppleIDProvider:
            "AppleID"
        case _ as ASAuthorizationPasswordProvider:
            "Password"
        case _ as ASAuthorizationPlatformPublicKeyCredentialProvider:
            "PlatformPublicKey"
        case _ as ASAuthorizationSecurityKeyPublicKeyCredentialProvider:
            "SecurityKeyPublicKey"
        case _ as ASAuthorizationSingleSignOnProvider:
            "SSO"
        default:
            "Others"
        }
    }
}
