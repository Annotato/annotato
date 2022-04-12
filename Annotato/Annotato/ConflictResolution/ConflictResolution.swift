struct ConflictResolution<T> {
    var localCreate: [T] = []
    var localUpdate: [T] = []
    var localDelete: [T] = []

    var serverCreate: [T] = []
    var serverUpdate: [T] = []
    var serverDelete: [T] = []

    var nonConflictingModels: [T] = []
    var conflictingModels: [(T, T)] = []
}
