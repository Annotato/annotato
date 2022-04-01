extension Array {
    mutating func appendIfNotNil(_ newElement: Element?) {
        if let element = newElement {
            self.append(element)
        }
    }
}
