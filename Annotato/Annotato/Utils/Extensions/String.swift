extension String {
    var isEmptyOrWhitespaceOnly: Bool {
        self.trimmingCharacters(in: .whitespaces).isEmpty
    }
}
