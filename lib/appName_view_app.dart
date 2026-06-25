import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'app_constants.dart';

class AppNameApp extends StatefulWidget {
  const AppNameApp({super.key});

  @override
  State<AppNameApp> createState() => _AppNameAppState();
}

class _AppNameAppState extends State<AppNameApp> {
  InAppWebViewController? webViewController;
  final ValueNotifier<double> _progressNotifier = ValueNotifier<double>(0.0);
  final ValueNotifier<String?> _errorNotifier = ValueNotifier<String?>(null);

  //JavaScript to hide social login
  static const String _hideSocialLoginScript = """
(function () {
  const css = `
    .s-login-modal-social-buttons, 
    .s-user-auth-modal-social,
    .s-login-modal-social-separator,
    [class*="divider"] {
      display: none !important;
      visibility: hidden !important;
      opacity: 0 !important;
      height: 0 !important;
      margin: 0 !important;
      padding: 0 !important;
      pointer-events: none !important;
      position: absolute !important;
    }
  `;

  function inject() {
    if (document.getElementById('kill-social-final')) return;
    const style = document.createElement('style');
    style.id = 'kill-social-final';
    style.innerHTML = css;
    if (document.head) {
        document.head.appendChild(style);
    }
  }

  inject();
  setInterval(inject, 500); 

  const observer = new MutationObserver(inject);
  observer.observe(document.documentElement, {
    childList: true,
    subtree: true
  });
})();
""";

  @override
  void dispose() {
    _progressNotifier.dispose();
    _errorNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            //* ---- Linear Progress Indicator ----
            ValueListenableBuilder<double>(
              valueListenable: _progressNotifier,
              builder: (context, progress, child) {
                if (progress < 1.0) {
                  return LinearProgressIndicator(
                    value: progress,
                    color: AppConstants.primaryColor,
                    backgroundColor: Colors.transparent,
                    minHeight: 3,
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            //* ---- WebView ----
            Expanded(
              child: Stack(
                children: [
                  InAppWebView(
                    initialUrlRequest: URLRequest(
                      url: WebUri(AppConstants.initialUrl),
                    ),
                    initialSettings: InAppWebViewSettings(
                      javaScriptEnabled: true,
                      domStorageEnabled: true,
                      databaseEnabled: true,
                      cacheEnabled: true,
                      hardwareAcceleration: true,
                      transparentBackground: true,
                      supportMultipleWindows: true,
                      javaScriptCanOpenWindowsAutomatically: true,
                    ),
                    initialUserScripts: UnmodifiableListView<UserScript>([
                      UserScript(
                        source: _hideSocialLoginScript,
                        injectionTime:
                            UserScriptInjectionTime.AT_DOCUMENT_START,
                        forMainFrameOnly: false,
                      ),
                    ]),
                    onWebViewCreated: (controller) {
                      webViewController = controller;
                    },
                    onLoadStart: (controller, url) {
                      _progressNotifier.value = 0.0;
                      _errorNotifier.value = null;
                    },
                    onProgressChanged: (controller, progress) {
                      _progressNotifier.value = progress / 100;
                    },
                    onLoadStop: (controller, url) async {
                      _progressNotifier.value = 1.0;
                      await controller.evaluateJavascript(
                        source: _hideSocialLoginScript,
                      );
                    },
                    onUpdateVisitedHistory: (controller, url, isReload) async {
                      await controller.evaluateJavascript(
                        source: _hideSocialLoginScript,
                      );
                    },
                    // ignore: deprecated_member_use
                    onLoadError: (controller, url, code, message) {
                      _errorNotifier.value = message;
                    },
                  ),
                  //* White Overlay
                  ValueListenableBuilder<double>(
                    valueListenable: _progressNotifier,
                    builder: (context, progress, child) {
                      bool isStarting = progress < 0.15;
                      return AnimatedOpacity(
                        opacity: isStarting ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 500),
                        child: IgnorePointer(
                          ignoring: !isStarting,
                          child: Container(color: Colors.white),
                        ),
                      );
                    },
                  ),

                  /// Error Screen
                  ValueListenableBuilder<String?>(
                    valueListenable: _errorNotifier,
                    builder: (context, errorMessage, child) {
                      if (errorMessage != null) {
                        return _buildErrorWidget();
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// This method is used to build the error widget
  /// when the webview fails to load
  Widget _buildErrorWidget() {
    return Container(
      color: Colors.white,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 150,
                width: 150,
                child: Image.asset(AppConstants.splashScreenImage),
              ),
              const SizedBox(height: 16),
              const Text(
                'حدث خطأ في تحميل الصفحة',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                _errorNotifier.value!,
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  color: Colors.black54,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  _errorNotifier.value = null;
                  webViewController?.reload();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.primaryColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                icon: const Icon(Icons.refresh, color: Colors.white, size: 18),
                label: const Text(
                  'إعادة المحاولة',
                  style: TextStyle(fontFamily: 'Cairo', color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
