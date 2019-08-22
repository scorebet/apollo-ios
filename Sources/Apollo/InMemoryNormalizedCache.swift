public final class InMemoryNormalizedCache: NormalizedCache {
    private var records: RecordSet
    private let queue: DispatchQueue

    public init(records: RecordSet = RecordSet()) {
        self.records = records
        self.queue = DispatchQueue(label: "com.apollographql.InMemoryNormalizedCache", attributes: .concurrent)
    }

    public func loadRecords(forKeys keys: [CacheKey]) -> Promise<[Record?]> {
        return Promise<[Record?]> { fulfill, reject in
            queue.async(flags: .barrier) {
                let records = keys.map { self.records[$0] }
                fulfill(records)
            }
        }
    }

    public func merge(records: RecordSet) -> Promise<Set<CacheKey>> {
        return Promise<Set<CacheKey>> { fulfill, reject in
            queue.async(flags: .barrier) {
                fulfill(self.records.merge(records: records))
            }
        }
    }

    public func clear() -> Promise<Void> {
        return Promise<Void> { fulfill, reject in
            queue.async {
                self.records.clear()
                fulfill(())
            }
        }
    }
}
