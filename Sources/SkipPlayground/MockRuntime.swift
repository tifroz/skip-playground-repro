import Foundation

#if !SKIP_BRIDGE
public enum MockRuntime {
    public static func normalize(identifier: String) -> String {
        identifier.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }

    public static func makeClientRefs(prefix: String, count: Int) -> [String] {
        (0..<count).map { "\(prefix):\($0)" }
    }
}
#endif
