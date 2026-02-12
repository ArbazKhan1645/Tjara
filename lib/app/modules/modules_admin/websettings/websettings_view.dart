import 'package:flutter/material.dart';
import 'package:tjara/app/core/widgets/admin_app_bar_actions.dart';
import 'package:tjara/app/modules/modules_admin/websettings/web_view_widget.dart';

class WebSettingsView extends StatefulWidget {
  const WebSettingsView({super.key});

  @override
  State<WebSettingsView> createState() => _WebSettingsViewState();
}

class _WebSettingsViewState extends State<WebSettingsView> {
  @override
  Widget build(BuildContext context) {
    const expandedStackGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFFF97316), Color(0xFFFACC15)],
    );
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF97316),
        actions: [const AdminAppBarActionsSimple()],
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Dashboard', style: TextStyle(color: Colors.white)),
      ),
      backgroundColor: Colors.grey.shade100,
      body: Stack(
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.4,
            decoration: const BoxDecoration(gradient: expandedStackGradient),
          ),
          const WebViewWidget(isAppBarExpanded: true),
        ],
      ),
    );
  }
}
