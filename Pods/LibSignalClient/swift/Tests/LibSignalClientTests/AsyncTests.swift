//
// Copyright 2023 Signal Messenger, LLC.
// SPDX-License-Identifier: AGPL-3.0-only
//

// These testing endpoints aren't generated in device builds, to save on code size.
#if !os(iOS) || targetEnvironment(simulator)

@testable import LibSignalClient
import SignalFfi
import XCTest

extension SignalCPromiseMutPointerTestingHandleType: LibSignalClient.PromiseStruct {
    public typealias Result = SignalMutPointerTestingHandleType
}

extension SignalCPromiseMutPointerOtherTestingHandleType: LibSignalClient.PromiseStruct {
    public typealias Result = SignalMutPointerOtherTestingHandleType
}

extension SignalFfi.SignalMutPointerTestingHandleType: LibSignalClient.SignalMutPointer {
    public typealias ConstPointer = SignalConstPointerTestingHandleType

    public init(untyped: OpaquePointer?) {
        self.init(raw: untyped)
    }

    public func toOpaque() -> OpaquePointer? {
        self.raw
    }

    public func const() -> Self.ConstPointer {
        Self.ConstPointer(raw: self.raw)
    }
}

extension SignalFfi.SignalConstPointerTestingHandleType: LibSignalClient.SignalConstPointer {
    public func toOpaque() -> OpaquePointer? {
        self.raw
    }
}

extension SignalFfi.SignalMutPointerOtherTestingHandleType: LibSignalClient.SignalMutPointer {
    public typealias ConstPointer = SignalConstPointerOtherTestingHandleType

    public init(untyped: OpaquePointer?) {
        self.init(raw: untyped)
    }

    public func toOpaque() -> OpaquePointer? {
        self.raw
    }

    public func const() -> Self.ConstPointer {
        Self.ConstPointer(raw: self.raw)
    }
}

extension SignalFfi.SignalConstPointerOtherTestingHandleType: LibSignalClient.SignalConstPointer {
    public func toOpaque() -> OpaquePointer? {
        self.raw
    }
}

extension SignalFfi.SignalMutPointerTestingFutureCancellationCounter: LibSignalClient.SignalMutPointer {
    public typealias ConstPointer = SignalConstPointerTestingFutureCancellationCounter

    public init(untyped: OpaquePointer?) {
        self.init(raw: untyped)
    }

    public func toOpaque() -> OpaquePointer? {
        self.raw
    }

    public func const() -> Self.ConstPointer {
        Self.ConstPointer(raw: self.raw)
    }
}

extension SignalFfi.SignalConstPointerTestingFutureCancellationCounter: LibSignalClient.SignalConstPointer {
    public func toOpaque() -> OpaquePointer? {
        self.raw
    }
}

private final class CancelCounter: NativeHandleOwner<SignalMutPointerTestingFutureCancellationCounter>,
    @unchecked
    Sendable
{
    public convenience init(initialValue: UInt8 = 0) {
        var out = SignalMutPointerTestingFutureCancellationCounter()
        failOnError {
            try checkError(signal_testing_future_cancellation_counter_create(&out, initialValue))
        }
        self.init(owned: NonNull(out)!)
    }

    public func waitForCount(asyncContext: TokioAsyncContext, target: UInt8) async throws {
        let _: Bool = try await asyncContext.invokeAsyncFunction { promise, asyncContext in
            self.withNativeHandle {
                signal_testing_future_cancellation_counter_wait_for_count(
                    promise,
                    asyncContext.const(),
                    $0.const(),
                    target
                )
            }
        }
    }

    override static func destroyNativeHandle(
        _ nativeHandle: NonNull<SignalMutPointerTestingFutureCancellationCounter>
    ) -> SignalFfiErrorRef? {
        signal_testing_future_cancellation_counter_destroy(nativeHandle.pointer)
    }
}

final class AsyncTests: TestCaseBase {
    func testSuccess() async throws {
        let result: Int32 = try await invokeAsyncFunction {
            signal_testing_future_success(
                $0,
                SignalConstPointerNonSuspendingBackgroundThreadRuntime(raw: OpaquePointer(bitPattern: -1)),
                21
            )
        }
        XCTAssertEqual(42, result)
    }

    func testFailure() async throws {
        do {
            let _: Int32 = try await invokeAsyncFunction {
                signal_testing_future_failure(
                    $0,
                    SignalConstPointerNonSuspendingBackgroundThreadRuntime(raw: OpaquePointer(bitPattern: -1)),
                    21
                )
            }
            XCTFail("should have failed")
        } catch SignalError.invalidArgument(_) {
            // good
        }
    }

    func testInvokeAsyncHandleTypes() async throws {
        do {
            let value = UInt8(44)
            let handle = try await invokeAsyncFunction {
                signal_testing_future_produces_pointer_type(
                    $0,
                    SignalConstPointerNonSuspendingBackgroundThreadRuntime(raw: OpaquePointer(bitPattern: -1)),
                    value
                )
            }
            defer { signal_testing_handle_type_destroy(handle) }
            XCTAssertEqual(
                try invokeFnReturningInteger { result in
                    signal_testing_testing_handle_type_get_value(result, handle.const())
                },
                value
            )
        }

        do {
            let value = "into the future"
            let otherHandle = try await invokeAsyncFunction {
                signal_testing_future_produces_other_pointer_type(
                    $0,
                    SignalConstPointerNonSuspendingBackgroundThreadRuntime(raw: OpaquePointer(bitPattern: -1)),
                    value
                )
            }
            defer { signal_other_testing_handle_type_destroy(otherHandle) }

            XCTAssertEqual(
                try invokeFnReturningString { result in
                    signal_testing_other_testing_handle_type_get_value(result, otherHandle.const())
                },
                value
            )
        }
    }

    func testTokioCancellation() async throws {
        let asyncContext = TokioAsyncContext()

        // We can replace this with AsyncStream.makeStream(...) when we update our builder.
        var _continuation: AsyncStream<Int>.Continuation!
        let completionStream = AsyncStream<Int> { _continuation = $0 }
        let continuation = _continuation!
        let counter = CancelCounter()

        let makeTask = { (id: Int, counter: CancelCounter) in
            Task {
                defer {
                    // Do this unconditionally so that the outer test procedure doesn't get stuck.
                    continuation.yield(id)
                }
                do {
                    _ = try await asyncContext.invokeAsyncFunction { promise, asyncContext in
                        counter.withNativeHandle { counter in
                            signal_testing_future_increment_on_cancel(promise, asyncContext.const(), counter.const())
                        }
                    }
                } catch is CancellationError {
                    // Okay, expected.
                } catch {
                    XCTFail("incorrect error: \(error)")
                }
            }
        }
        let task1 = makeTask(1, counter)
        let task2 = makeTask(2, counter)

        var completionIter = completionStream.makeAsyncIterator()

        // Complete the tasks in opposite order of starting them,
        // to make it less likely to get this result by accident.
        // This is not a rigorous test, only a simple exercise of the feature.
        task2.cancel()
        let firstCompletionId = await completionIter.next()
        XCTAssertEqual(firstCompletionId, 2)

        task1.cancel()
        let secondCompletionId = await completionIter.next()
        XCTAssertEqual(secondCompletionId, 1)

        try await counter.waitForCount(asyncContext: asyncContext, target: 2)
    }
}

#endif
