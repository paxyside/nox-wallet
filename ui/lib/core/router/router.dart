import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nox/core/balance/balance_grpc_repository.dart';
import 'package:nox/core/router/routes.dart';
import 'package:nox/core/theme/app_colors.dart';
import 'package:nox/core/widgets/app_dialog.dart';
import 'package:nox/core/widgets/app_snack_bar.dart';
import 'package:nox/core/widgets/sidebar.dart';
import 'package:nox/features/approvals/presentation/screens/approvals_screen.dart';
import 'package:nox/features/contacts/presentation/screens/contacts_screen.dart';
import 'package:nox/features/history/presentation/screens/history_screen.dart';
import 'package:nox/features/home/presentation/screens/home_screen.dart';
import 'package:nox/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:nox/features/send/presentation/providers/send_provider.dart';
import 'package:nox/features/send/presentation/screens/send_screen.dart';
import 'package:nox/features/send/presentation/widgets/send_result_dialog.dart';
import 'package:nox/features/settings/presentation/screens/settings_screen.dart';
import 'package:nox/features/swap/presentation/providers/swap_provider.dart';
import 'package:nox/features/swap/presentation/screens/swap_screen.dart';
import 'package:nox/features/swap/presentation/widgets/swap_result_dialog.dart';
import 'package:nox/features/tokens/presentation/screens/tokens_screen.dart';

// ---------------------------------------------------------------------------
// Wallet existence provider — drives the auth redirect
// ---------------------------------------------------------------------------

final walletExistsProvider = FutureProvider<bool>(
  (ref) => const BalanceGrpcRepository().walletExists(),
);

// ---------------------------------------------------------------------------
// Router notifier — refreshes go_router when wallet state changes
// ---------------------------------------------------------------------------

class _RouterNotifier extends ChangeNotifier {
  _RouterNotifier(this._ref) {
    _ref.listen<AsyncValue<bool>>(walletExistsProvider, (_, _) {
      notifyListeners();
    });
  }

  final Ref _ref;

  String? redirect(BuildContext context, GoRouterState state) {
    final walletAsync = _ref.read(walletExistsProvider);
    if (walletAsync.isLoading) return null;
    final hasWallet = walletAsync.valueOrNull ?? false;
    final inOnboarding = state.matchedLocation.startsWith('/onboarding');
    if (!hasWallet && !inOnboarding) return Routes.onboarding;
    if (hasWallet && inOnboarding) return Routes.home;
    return null;
  }
}

// ---------------------------------------------------------------------------
// Router provider
// ---------------------------------------------------------------------------

final routerProvider = Provider<GoRouter>((ref) {
  final notifier = _RouterNotifier(ref);
  return GoRouter(
    initialLocation: Routes.home,
    refreshListenable: notifier,
    redirect: notifier.redirect,
    routes: [
      GoRoute(
        path: Routes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: Routes.home,
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: Routes.send,
            builder: (context, state) => SendScreen(
              // Quick-action from Tokens screen passes the contract address
              // here as `?token=0x…`; SendScreen pre-selects it on mount.
              initialTokenAddress: state.uri.queryParameters['token'],
            ),
          ),
          GoRoute(
            path: Routes.swap,
            builder: (context, state) => SwapScreen(
              // Quick-action from Tokens → pre-fills the PAY side.
              initialTokenInAddress: state.uri.queryParameters['tokenIn'],
            ),
          ),
          GoRoute(
            path: Routes.history,
            builder: (context, state) => const HistoryScreen(),
          ),
          GoRoute(
            path: Routes.contacts,
            builder: (context, state) => const ContactsScreen(),
          ),
          GoRoute(
            path: Routes.tokens,
            builder: (context, state) => const TokensScreen(),
          ),
          GoRoute(
            path: Routes.approvals,
            builder: (context, state) => const ApprovalsScreen(),
          ),
          GoRoute(
            path: Routes.settings,
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
    ],
  );
});

// ---------------------------------------------------------------------------
// App shell
// ---------------------------------------------------------------------------

class AppShell extends ConsumerWidget {
  const AppShell({required this.child, super.key});
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // App-level listener for Send result. Lives here (not on SendScreen) so
    // the success / failure dialog still shows after the user has navigated
    // away mid-broadcast — otherwise the listener disappears with the
    // unmounted screen and the user gets no closure.
    ref.listen<SendState>(sendNotifierProvider, (prev, next) {
      final justFinished =
          (prev?.status != SendStatus.success && next.status == SendStatus.success) ||
          (prev?.status != SendStatus.failure && next.status == SendStatus.failure);
      if (!justFinished) return;
      final amount = next.amount;
      final symbol = next.selectedAsset?.symbol ?? 'ETH';
      final hash = next.txResult?.txHash ?? '';
      final success = next.status == SendStatus.success;
      final errorMsg = next.errorMessage;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        // Use the dialog navigator from the messenger context — it's always
        // available regardless of which child route is mounted.
        final messenger = AppSnackBar.messengerKey.currentContext;
        if (messenger == null) return;
        // true  = "Send Another" (reset + navigate to Send)
        // false = "Close"        (reset, stay on current screen)
        final sendAnother = await showAppDialog<bool>(
          context: messenger,
          barrierDismissible: false,
          builder: (_) => SendResultDialog(
            success: success,
            txHash: hash,
            amount: amount,
            symbol: symbol,
            errorMessage: errorMsg,
          ),
        );
        ref.read(sendNotifierProvider.notifier).reset();
        if (sendAnother == true && messenger.mounted) {
          messenger.go(Routes.send);
        }
      });
    });

    // Same pattern for Swap. Surfaces a richer success / failure modal
    // (SwapResultDialog) instead of the previous content-area SnackBar so
    // the outcome is consistent with Send and survives navigation.
    // ignore: cascade_invocations
    ref.listen<SwapState>(swapNotifierProvider, (prev, next) {
      final justFinished =
          (prev?.status != SwapStatus.success && next.status == SwapStatus.success) ||
          (prev?.status != SwapStatus.failure && next.status == SwapStatus.failure);
      if (!justFinished) return;
      final amountIn = next.amountIn;
      final amountOut = next.quote?.amountOut ?? '';
      final assets = ref.read(swappableAssetsProvider).valueOrNull ?? [];
      String symbolFor(String addr) {
        if (addr.isEmpty) return '';
        try {
          return assets.firstWhere((a) => a.address == addr).symbol;
        } on Object catch (_) {
          return '';
        }
      }

      final symbolIn = symbolFor(next.tokenIn);
      final symbolOut = symbolFor(next.tokenOut);
      final hash = next.txHash ?? '';
      final success = next.status == SwapStatus.success;
      final errorMsg = next.errorMessage;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final messenger = AppSnackBar.messengerKey.currentContext;
        if (messenger == null) return;
        final swapAgain = await showAppDialog<bool>(
          context: messenger,
          barrierDismissible: false,
          builder: (_) => SwapResultDialog(
            success: success,
            txHash: hash,
            amountIn: amountIn,
            symbolIn: symbolIn,
            amountOut: amountOut,
            symbolOut: symbolOut,
            errorMessage: errorMsg,
          ),
        );
        ref.read(swapNotifierProvider.notifier).reset();
        if (swapAgain == true && messenger.mounted) {
          messenger.go(Routes.swap);
        }
      });
    });

    return Scaffold(
      backgroundColor: context.colors.background,
      body: Row(
        children: [
          const Sidebar(),
          VerticalDivider(width: 1, color: context.colors.border),
          // Wrap content in its own ScaffoldMessenger so SnackBars appear
          // only in the content area, not over the sidebar.
          Expanded(
            child: ScaffoldMessenger(
              key: AppSnackBar.messengerKey,
              child: Scaffold(
                backgroundColor: context.colors.background,
                body: child,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
