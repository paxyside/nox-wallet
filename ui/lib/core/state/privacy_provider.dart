import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'privacy_provider.g.dart';

/// When `true`, all monetary amounts in the UI are masked as `***`.
/// Useful when screen-sharing or filming a demo.
@Riverpod(keepAlive: true)
class HideBalances extends _$HideBalances {
  @override
  bool build() => false;

  void toggle() {
    state = !state;
  }

  void setHidden({required bool hidden}) {
    if (hidden == state) return;
    state = hidden;
  }
}
