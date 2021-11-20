enum CeremonyPhase { REGISTERING, ASSIGNING, ATTESTING }

// this becomes possible if dart min SDK > 2.6
// extension FromStringExtension on CeremonyPhase {
//
//   CeremonyPhase fromString(String value) {
//     return ceremonyPhaseFromString(value);
//   }
// }

/// Parses a String into an enum
/// Recognizes patterns like: CeremonyPhase.Registering, CeremonyPhase.REGISTERING, Registering, REGISTERING,
T getEnumFromString<T>(Iterable<T> values, String value) {
  return values.firstWhere(
    (type) => type.toString().split(".").last == value.toString().split(".").last.toUpperCase(),
    orElse: () => null,
  );
}

CeremonyPhase ceremonyPhaseFromString(String value) {
  return getEnumFromString(CeremonyPhase.values, value);
}

String toValue(CeremonyPhase phase) {
  String p = phase.toString().split(".").last;
  // return capitalized values
  return "${p[0].toUpperCase()}${p.substring(1).toLowerCase()}";
}
