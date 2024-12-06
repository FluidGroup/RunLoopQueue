import CATransactionQueue

@MainActor
public func withPrerender(_ body: @escaping @MainActor () -> Void) {
  CATransactionQueue.shared.enqueue(work: body)
}
