import Foundation

public protocol TestExecutor: AnyObject {
    var type: TestExecutorType { get }
    var UDID: String { get }
    var finished: Bool { get set }
    
    func ready(completion: @escaping (Bool) -> Void)
    func run(tests: [String], timeout: Int, completion: ((TestExecutor, Result<[String], TestExecutorError>) -> Void)?)
    func reset(completion: ((Result<TestExecutor, Error>) -> Void)?)
    func deleteApp(bundleId: String)
}

public enum TestExecutorType: String {
    case simulator = "iOS Simulator"
    case device = "iOS"
	case macOS = "macOS"
}

public enum TestExecutorError: Error {
    case noTestsForExecution
    case executionError(description: String, tests: [String])
    case testSkipped
}
