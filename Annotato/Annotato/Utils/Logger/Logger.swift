import SwiftyBeaver

class Logger: AnnotatoLoggerService {
    let log: SwiftyBeaver.Type

    init() {
        let console = ConsoleDestination()
        // See https://docs.swiftybeaver.com/article/20-custom-format
        console.format = "LOG($DHH:mm:ss$d) $C$L:$c $M"
        log = SwiftyBeaver.self
        log.addDestination(console)
    }

    func verbose(_ message: String) {
        log.verbose(message)
    }

    func debug(_ message: String) {
        log.debug(message)
    }

    func info(_ message: String) {
        log.info(message)
    }

    func warning(_ message: String) {
        log.warning(message)
    }

    func error(_ message: String) {
        log.error(message)
    }
}
