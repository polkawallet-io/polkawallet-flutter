enum CeremonyPhase { REGISTERING, ASSIGNING, ATTESTING }

/// Parses a String into an enum
/// Recognizes patterns like: CeremonyPhase.Registering, CeremonyPhase.REGISTERING, Registering, REGISTERING,
T getEnumFromString<T>(Iterable<T> values, String value) {
  return values.firstWhere(
    (type) => type.toString().split(".").last == value.toString().split(".").last.toUpperCase(),
    orElse: () => null,
  );
}
