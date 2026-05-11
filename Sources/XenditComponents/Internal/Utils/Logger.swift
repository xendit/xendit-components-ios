//
//  Logger.swift
//  XenditComponents
//
//  Created by Ahmad X on 07/04/2026.
//

import CocoaLumberjackSwift
import Foundation

/*
 A wrapper around logger used, so it will be easier to change logger when needed

 Logger.info("Hello world")
 Logger("API").error("Invalid response")
 */

struct Logger {
    static var enabled = false

    init(_ tag: String = "") {
        self.tag = tag
        var message = ""
        if let prefix = Logger.prefix, !prefix.isEmpty {
            message = "[\(prefix)]"
        }
        if !tag.isEmpty {
            message += "[\(tag)] "
        }
        tagMessage = message
    }

    static func setup(prefix: String? = nil) {
        enabled = true
        self.prefix = prefix
        DDLog.add(DDOSLogger.sharedInstance)
    }

    static func verbose(_ message: String) {
        shared.log(.verbose, message)
    }

    static func verbose(_ format: String, _ args: CVarArg...) {
        shared.log(.verbose, format, args)
    }

    static func debug(_ message: String) {
        shared.log(.debug, message)
    }

    static func debug(_ format: String, _ args: CVarArg...) {
        shared.log(.debug, format, args)
    }

    static func info(_ message: String) {
        shared.log(.info, message)
    }

    static func info(_ format: String, _ args: CVarArg...) {
        shared.log(.info, format, args)
    }

    static func warning(_ message: String) {
        shared.log(.warning, message)
    }

    static func warning(_ format: String, _ args: CVarArg...) {
        shared.log(.warning, format, args)
    }

    static func error(_ message: String) {
        shared.log(.error, message)
    }

    static func error(_ format: String, _ args: CVarArg...) {
        shared.log(.error, format, args)
    }

    func verbose(_ message: String) {
        log(.verbose, tagMessage + message)
    }

    func verbose(_ format: String, _ args: CVarArg...) {
        log(.verbose, tagMessage + format, args)
    }

    func debug(_ message: String) {
        log(.debug, tagMessage + message)
    }

    func debug(_ format: String, _ args: CVarArg...) {
        log(.debug, tagMessage + format, args)
    }

    func info(_ message: String) {
        log(.info, tagMessage + message)
    }

    func info(_ format: String, _ args: CVarArg...) {
        log(.info, tagMessage + format, args)
    }

    func warning(_ message: String) {
        log(.warning, tagMessage + message)
    }

    func warning(_ format: String, _ args: CVarArg...) {
        log(.warning, tagMessage + format, args)
    }

    func error(_ message: String) {
        log(.error, tagMessage + message)
    }

    func error(_ format: String, _ args: CVarArg...) {
        log(.error, tagMessage + format, args)
    }

    // MARK: - Private

    private enum Level {
        case verbose, debug, info, warning, error
    }

    private static let shared = Logger()
    private static var prefix: String?

    private let tag: String
    private let tagMessage: String

    private func log(_ level: Level, _ format: String, _ args: CVarArg...) {
        log(level, String(format: format, arguments: args))
    }

    private func log(_ level: Level, _ message: String) {
        guard Logger.enabled else { return }
        switch level {
        case .verbose:
            DDLogVerbose(message)
        case .debug:
            DDLogDebug(message)
        case .info:
            DDLogInfo(message)
        case .warning:
            DDLogWarn(message)
        case .error:
            DDLogError(message)
        }
    }
}
