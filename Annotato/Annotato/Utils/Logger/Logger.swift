import SwiftyBeaver

class Logger: AnnotatoLoggerService {
    let log: SwiftyBeaver.Type

    init() {
        let console = ConsoleDestination()
        // See https://docs.swiftybeaver.com/article/20-custom-format
        console.format = "TIME: $DHH:mm:ss$d $X $C$L:$c $M"
        log = SwiftyBeaver.self
        log.addDestination(console)
    }

    func verbose(_ message: String, context: String?) {
        log.verbose(message, context: context)
    }

    func debug(_ message: String, context: String?) {
        log.debug(message, context: context)
    }

    func info(_ message: String, context: String?) {
        log.info(message, context: context)
    }

    func warning(_ message: String, context: String?) {
        log.warning(message, context: context)
    }

    func error(_ message: String, context: String?) {
        log.error(message, context: context)
    }
}
