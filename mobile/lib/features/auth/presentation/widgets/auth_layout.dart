import 'package:flutter/material.dart';

class AuthLayout extends StatelessWidget {
  final Widget child;
  final String title;
  final String subtitle;
  final bool showLogo;
  final VoidCallback? onBack;
  final bool isBackEnabled;
  final bool titleInAppBar;

  const AuthLayout({
    super.key,
    required this.child,
    required this.title,
    required this.subtitle,
    this.showLogo = true,
    this.onBack,
    this.isBackEnabled = true,
    this.titleInAppBar = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: onBack != null
          ? AppBar(
              title: titleInAppBar
                  ? Text(
                      title,
                      style: TextStyle(color: theme.colorScheme.primary),
                    )
                  : null,
              centerTitle: true,
              backgroundColor: Colors.transparent,
              elevation: 0,
              surfaceTintColor: Colors.transparent,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                onPressed: isBackEnabled ? onBack : null,
              ),
            )
          : null,
      body: SafeArea(
        bottom: true,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            24,
            onBack != null ? 8 : 32,
            24,
            32,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (showLogo) ...[
                const SizedBox(height: 4),
                Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text('🧠', style: TextStyle(fontSize: 40)),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              if (!titleInAppBar) ...[
                Text(
                  title,
                  style: theme.textTheme.displaySmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
              ],
              Text(
                subtitle,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              child,
            ],
          ),
        ),
      ),
    );
  }
}
