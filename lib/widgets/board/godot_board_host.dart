import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import '../../integration/godot_board_controller.dart';

class GodotBoardHost extends StatefulWidget {
  const GodotBoardHost({super.key, required this.controller});

  final GodotBoardController controller;

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
          const ColoredBox(
            color: Color(0xCC071126),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: Color(0xFFE4B64E)),
                  SizedBox(height: 16),
                  Text(
                    'Preparing 3D board…',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
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

class _BoardUnavailable extends StatelessWidget {
  const _BoardUnavailable();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: Color(0xFF071126),
      child: Center(
        child: Text(
          '3D board is not available on this platform yet.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white70),
        ),
      ),
    );
  }
}
