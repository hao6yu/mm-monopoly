import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import '../../integration/godot_board_controller.dart';
import '../../l10n/app_localizations.dart';

class GodotBoardHost extends StatefulWidget {
  const GodotBoardHost({
    super.key,
    required this.controller,
    this.onRetry,
    this.onUse2D,
  });

  final GodotBoardController controller;
  final Future<void> Function()? onRetry;
  final VoidCallback? onUse2D;

  @override
  State<GodotBoardHost> createState() => _GodotBoardHostState();
}

class _GodotBoardHostState extends State<GodotBoardHost> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_refresh);
  }

  @override
  void didUpdateWidget(GodotBoardHost oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_refresh);
      widget.controller.addListener(_refresh);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.controller.isAvailable) {
      return const _BoardUnavailable();
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: _buildPlatformView(),
        ),
        if (widget.controller.isLoading)
          _BoardPreparationOverlay(
            sceneReady: widget.controller.isSceneReady,
            error: widget.controller.stateApplyError,
            onRetry: widget.onRetry,
            onUse2D: widget.onUse2D,
          ),
      ],
    );
  }

  Widget _buildPlatformView() {
    const viewType = 'property_tycoon/godot_board';
    final gestureRecognizers = <Factory<OneSequenceGestureRecognizer>>{
      Factory<OneSequenceGestureRecognizer>(EagerGestureRecognizer.new),
    };

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return UiKitView(
        viewType: viewType,
        layoutDirection: TextDirection.ltr,
        hitTestBehavior: PlatformViewHitTestBehavior.opaque,
        gestureRecognizers: gestureRecognizers,
        onPlatformViewCreated: (_) => widget.controller.markViewCreated(),
      );
    }

    return PlatformViewLink(
      viewType: viewType,
      surfaceFactory: (context, platformController) {
        return AndroidViewSurface(
          controller: platformController as AndroidViewController,
          hitTestBehavior: PlatformViewHitTestBehavior.opaque,
          gestureRecognizers: gestureRecognizers,
        );
      },
      onCreatePlatformView: (params) {
        final platformController = PlatformViewsService.initSurfaceAndroidView(
          id: params.id,
          viewType: params.viewType,
          layoutDirection: TextDirection.ltr,
        );
        platformController.addOnPlatformViewCreatedListener(
          (_) => widget.controller.markViewCreated(),
        );
        return platformController
          ..addOnPlatformViewCreatedListener(params.onPlatformViewCreated)
          ..create();
      },
    );
  }
}

class _BoardPreparationOverlay extends StatelessWidget {
  const _BoardPreparationOverlay({
    required this.sceneReady,
    required this.error,
    required this.onRetry,
    required this.onUse2D,
  });

  final bool sceneReady;
  final GodotBoardStateApplyError? error;
  final Future<void> Function()? onRetry;
  final VoidCallback? onUse2D;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final error = this.error;
    final errorMessage = switch (error) {
      GodotBoardStateApplyError.rejected ||
      GodotBoardStateApplyError.deliveryFailed => l10n.failedToPrepare3DBoard,
      GodotBoardStateApplyError.connectionUnavailable =>
        l10n.godotConnectionUnavailable,
      GodotBoardStateApplyError.timedOut => l10n.godotPreparationTimedOut,
      null => null,
    };
    final statusMessage =
        errorMessage ??
        (sceneReady ? l10n.building3DBoard : l10n.starting3DBoard);
    return ColoredBox(
      // Keep the bootstrap city hidden until Godot confirms that it applied
      // the exact requested session generation.
      color: const Color(0xFF071126),
      child: Center(
        child: Semantics(
          liveRegion: true,
          label: statusMessage,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (error == null)
                  const CircularProgressIndicator(color: Color(0xFFE4B64E))
                else
                  const Icon(
                    Icons.view_in_ar_rounded,
                    color: Color(0xFFE4B64E),
                    size: 42,
                  ),
                const SizedBox(height: 16),
                Text(
                  statusMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (error != null) ...[
                  const SizedBox(height: 18),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      FilledButton.icon(
                        onPressed: onRetry == null
                            ? null
                            : () => onRetry!.call(),
                        icon: const Icon(Icons.refresh_rounded),
                        label: Text(l10n.retry3DBoard),
                      ),
                      OutlinedButton.icon(
                        onPressed: onUse2D,
                        icon: const Icon(Icons.grid_view_rounded),
                        label: Text(l10n.use2DBoard),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BoardUnavailable extends StatelessWidget {
  const _BoardUnavailable();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFF071126),
      child: Center(
        child: Text(
          AppLocalizations.of(context)!.godotConnectionUnavailable,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white70),
        ),
      ),
    );
  }
}
