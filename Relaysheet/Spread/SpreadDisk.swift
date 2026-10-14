import Foundation

/// File projection of the in-memory chart. IO stays off the main actor.
actor SpreadDisk {
    let fileURL: URL

    init(fileURL: URL) {
        self.fileURL = fileURL
    }

    func prepareDirectories() throws {
        let folder = fileURL.deletingLastPathComponent()
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        let cache = folder.appendingPathComponent("Cache", isDirectory: true)
        try FileManager.default.createDirectory(at: cache, withIntermediateDirectories: true)
        var values = URLResourceValues()
        values.isExcludedFromBackup = true
        var cacheURL = cache
        try cacheURL.setResourceValues(values)
    }

    func readPrimary() throws -> Data? {
        try readIfPresent(fileURL)
    }

    func readBackup() throws -> Data? {
        try readIfPresent(fileURL.appendingPathExtension("backup"))
    }

    /// Atomic replace. The previous good file is kept as `.backup` first.
    func writeAtomically(_ data: Data) throws {
        try prepareDirectories()
        let backup = fileURL.appendingPathExtension("backup")
        if FileManager.default.fileExists(atPath: fileURL.path) {
            if FileManager.default.fileExists(atPath: backup.path) {
                try FileManager.default.removeItem(at: backup)
            }
            try FileManager.default.copyItem(at: fileURL, to: backup)
        }
        try data.write(to: fileURL, options: .atomic)
    }

    func removeAll() throws {
        if FileManager.default.fileExists(atPath: fileURL.path) {
            try FileManager.default.removeItem(at: fileURL)
        }
        let backup = fileURL.appendingPathExtension("backup")
        if FileManager.default.fileExists(atPath: backup.path) {
            try FileManager.default.removeItem(at: backup)
        }
    }

    private func readIfPresent(_ url: URL) throws -> Data? {
        guard FileManager.default.fileExists(atPath: url.path) else { return nil }
        do {
            return try Data(contentsOf: url)
        } catch {
            throw error
        }
    }
}
