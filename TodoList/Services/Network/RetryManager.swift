struct RetryManager {
    let minDelay: Double
    let maxDelay: Double
    let factor: Double
    let jitter: Double

    init(
        minDelay: Double = 2,
        maxDelay: Double = 10,
        factor: Double = 1.5,
        jitter: Double = 0.05
    ) {
        self.minDelay = minDelay
        self.maxDelay = maxDelay
        self.factor = factor
        self.jitter = jitter
    }

    func run(_ closure: @escaping () async throws -> Void, onTimeout: ((Error) -> Void)? = nil) {
        Task {
            do {
                try await closure()
                return
            } catch {
                var iteration = 0
                var time = minDelay

                while time < maxDelay {
                    try Task.checkCancellation()

                    time = minDelay + Double(iteration) * factor
                    time = Double.random(in: (time - jitter...time + jitter))

                    do {
                        try await Task.sleep(for: .seconds(time))
                    } catch {
                        return
                    }

                    do {
                        try await closure()
                        return
                    } catch {
                        iteration += 1
                    }
                }
            }

            do {
                try await closure()
            } catch let error {
                onTimeout?(error)
            }
        }
    }
}
