class AnnotatoLogger {
    private static let shared = AnnotatoLogger()
    private var logService: AnnotatoLoggerService = Logger()

    private init() {}

    static func verbose(_ message: String) {
        shared.logService.verbose(message)
    }

    static func debug(_ message: String) {
        shared.logService.debug(message)
    }

    static func info(_ message: String) {
        shared.logService.info(message)
    }

    static func warning(_ message: String) {
        shared.logService.warning(message)
    }

    static func error(_ message: String) {
        shared.logService.error(message)
    }
}
