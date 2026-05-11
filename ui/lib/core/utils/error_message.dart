import 'package:grpc/grpc.dart';

// ---------------------------------------------------------------------------
// errorMessage — turn any error/Object into a user-readable string.
//
// Default `Error.toString()` for gRPC errors looks like:
//   "gRPC Error (code: 3, codeName: INVALID_ARGUMENT, message: ETH and WETH
//    are 1:1 — use wrap/unwrap, not swap, details: [], rawResponse: null,
//    trailers: {})"
//
// Almost none of that is useful to the user. This helper extracts just the
// `message` field for gRPC errors and falls back to `.toString()` for
// everything else, with a final "Something went wrong." for empty messages.
// ---------------------------------------------------------------------------

String errorMessage(Object? error) {
  if (error == null) return _fallback;

  if (error is GrpcError) {
    final msg = error.message?.trim() ?? '';
    if (msg.isNotEmpty) return _capitalise(msg);
    return _fallback;
  }

  // Riverpod often surfaces the wrapped error from inside an AsyncError;
  // strip the "Exception: " / "Error: " prefix some libs add.
  final raw = error.toString().trim();
  if (raw.isEmpty) return _fallback;
  final stripped = raw.replaceFirst(RegExp(r'^(Exception|Error|StateError):\s*'), '').trim();
  return _capitalise(stripped.isEmpty ? raw : stripped);
}

String _capitalise(String s) {
  if (s.isEmpty) return s;
  return s[0].toUpperCase() + s.substring(1);
}

const String _fallback = 'Something went wrong.';
