protocol AnnotatoLoggerService {
    func verbose(_ message: String, context: String?)
    func debug(_ message: String, context: String?)
    func info(_ message: String, context: String?)
    func warning(_ message: String, context: String?)
    func error(_ message: String, context: String?)
}
