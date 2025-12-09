import 'package:flutter/material.dart';

import '../presentation/socket_io/socket_controller.dart';

// Add this mixin to your main screen or wherever you use SocketController
mixin AppLifecycleHandler<T extends StatefulWidget> on State<T>, WidgetsBindingObserver {
  SocketController? socketController;

  void setSocketController(SocketController controller) {
    socketController = controller;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (socketController == null) return;

    switch (state) {
      case AppLifecycleState.resumed:
      // App came back to foreground
        print('📱 App resumed');
        socketController!.handleAppResume();
        break;
      case AppLifecycleState.paused:
      // App went to background
        print('📱 App paused');
        socketController!.handleAppPause();
        break;
      case AppLifecycleState.inactive:
      // App is transitioning (e.g., phone call)
        print('📱 App inactive');
        break;
      case AppLifecycleState.detached:
      // App is closing
        print('📱 App detached');
        socketController!.disconnectSocket();
        break;
      case AppLifecycleState.hidden:
        // TODO: Handle this case.
        throw UnimplementedError();
    }
  }
}

// ALTERNATIVE: If you want a wrapper widget instead
class AppLifecycleWrapper extends StatefulWidget {
  final Widget child;
  final SocketController socketController;

  const AppLifecycleWrapper({
    Key? key,
    required this.child,
    required this.socketController,
  }) : super(key: key);

  @override
  State<AppLifecycleWrapper> createState() => _AppLifecycleWrapperState();
}

class _AppLifecycleWrapperState extends State<AppLifecycleWrapper>
    with WidgetsBindingObserver {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.resumed:
        print('📱 App resumed');
        widget.socketController.handleAppResume();
        break;
      case AppLifecycleState.paused:
        print('📱 App paused');
        widget.socketController.handleAppPause();
        break;
      case AppLifecycleState.detached:
        print('📱 App detached');
        widget.socketController.disconnectSocket();
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
