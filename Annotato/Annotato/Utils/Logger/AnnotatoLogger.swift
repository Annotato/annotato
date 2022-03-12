import os

class AnnotatoLogger {
    private static let shared = AnnotatoLogger()
    private var logProvider: AnnotatoLoggerAdapter = Logger()

    private init() {}

    static func verbose(_ message: String) {
        shared.logProvider.verbose(message)
    }

    static func debug(_ message: String) {
        shared.logProvider.debug(message)
    }

    static func info(_ message: String) {
        shared.logProvider.info(message)
    }

    static func warning(_ message: String) {
        shared.logProvider.warning(message)
    }

    static func error(_ message: String) {
        shared.logProvider.error(message)
    }
}
