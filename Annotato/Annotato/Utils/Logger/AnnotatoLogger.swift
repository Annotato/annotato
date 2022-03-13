class AnnotatoLogger {
    private static let shared = AnnotatoLogger()
    private var logService: AnnotatoLoggerService = Logger()

    private init() {}

    static func verbose(_ message: String, context: String? = nil) {
        shared.logService.verbose(message, context: context)
    }

    static func debug(_ message: String, context: String? = nil) {
        shared.logService.debug(message, context: context)
    }

    static func info(_ message: String, context: String? = nil) {
        shared.logService.info(message, context: context)
    }

    static func warning(_ message: String, context: String? = nil) {
        shared.logService.warning(message, context: context)
    }

    static func error(_ message: String, context: String? = nil) {
        shared.logService.error(message, context: context)
    }
}
