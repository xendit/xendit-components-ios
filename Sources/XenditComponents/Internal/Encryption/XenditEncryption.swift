//
//  XenditEncryption.swift
//  XenditComponents
//
//  Created by Ahmad X on 30/04/2026.
//

import Foundation
import CryptoKit

internal enum XenditEncryption {

    // MARK: - Constants

    private static let gcmIvLength = 48
    private static let sessionKeyLength = 32

    // MARK: - Errors

    enum EncryptionError: Error {
        case invalidServerPublicKey
        case ivGenerationFailed
        case encryptionFailed(underlying: Error)
    }

    // MARK: - Public API

    /// Performs the full ECDH + HKDF + AES-GCM encryption flow.
    ///
    /// - Parameters:
    ///   - data: The plaintext to encrypt.
    ///   - serverPublicKeyBase64: Server's P-384 public key in X.509/SPKI DER, Base64-encoded.
    ///   - sessionId: Session identifier used as HKDF info and (hashed) as AES-GCM AAD.
    /// - Returns: `xendit-encrypted-1-<pubKey>-<iv>-<ciphertext+tag>`.
    static func encrypt(
        data: String,
        serverPublicKeyBase64: String,
        sessionId: String
    ) throws -> String {
        do {
            // 1. Ephemeral P-384 key pair (P384 == secp384r1)
            let ownPrivateKey = P384.KeyAgreement.PrivateKey()
            let ownPublicKey = ownPrivateKey.publicKey

            // 2. Decode server's public key (SPKI / X.509 DER)
            guard let serverKeyBytes = Data(base64Encoded: serverPublicKeyBase64) else {
                throw EncryptionError.invalidServerPublicKey
            }
            let serverPublicKey = try P384.KeyAgreement.PublicKey(
                derRepresentation: serverKeyBytes
            )

            // 3. ECDH shared secret
            let sharedSecret = try ownPrivateKey.sharedSecretFromKeyAgreement(
                with: serverPublicKey
            )

            // 4. HKDF-SHA256 → 32-byte session key (empty salt, sessionId as info)
            let info = Data(sessionId.utf8)
            let sessionKey = sharedSecret.hkdfDerivedSymmetricKey(
                using: SHA256.self,
                salt: Data(),
                sharedInfo: info,
                outputByteCount: sessionKeyLength
            )

            // 5. Random 48-byte IV (matches Kotlin GCM_IV_LENGTH = 48)
            var ivBytes = [UInt8](repeating: 0, count: gcmIvLength)
            let status = SecRandomCopyBytes(kSecRandomDefault, gcmIvLength, &ivBytes)
            guard status == errSecSuccess else {
                throw EncryptionError.ivGenerationFailed
            }
            let iv = Data(ivBytes)
            let nonce = try AES.GCM.Nonce(data: iv)

            // 6. AAD = SHA-256(sessionId)
            let aad = Data(SHA256.hash(data: Data(sessionId.utf8)))

            // 7. AES-GCM seal
            let sealedBox = try AES.GCM.seal(
                Data(data.utf8),
                using: sessionKey,
                nonce: nonce,
                authenticating: aad
            )

            // Java's Cipher.doFinal returns ciphertext || tag concatenated.
            // CryptoKit splits them, so re-concatenate to keep the wire format identical.
            let ciphertextWithTag = sealedBox.ciphertext + sealedBox.tag

            // 8. Encode and assemble
            let ownPublicKeyB64 = ownPublicKey.derRepresentation.base64EncodedString()
            let ivB64 = iv.base64EncodedString()
            let ciphertextB64 = ciphertextWithTag.base64EncodedString()

            return "xendit-encrypted-1-\(ownPublicKeyB64)-\(ivB64)-\(ciphertextB64)"
        } catch let error as EncryptionError {
            throw error
        } catch {
            throw EncryptionError.encryptionFailed(underlying: error)
        }
    }
}
