import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Composant pour ouvrir des liens externes
class ExternalLink extends StatelessWidget {
  final String url;
  final String? text;
  final Widget? child;
  final TextStyle? style;
  final Color? color;
  final IconData? icon;
  final bool showIcon;

  const ExternalLink({
    super.key,
    required this.url,
    this.text,
    this.child,
    this.style,
    this.color,
    this.icon,
    this.showIcon = true,
  });

  Future<void> _launchUrl(BuildContext context) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Impossible d\'ouvrir le lien: $url'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (child != null) {
      return InkWell(
        onTap: () => _launchUrl(context),
        child: child,
      );
    }

    return InkWell(
      onTap: () => _launchUrl(context),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text ?? url,
            style: style ??
                TextStyle(
                  color: color ?? Colors.blue,
                  decoration: TextDecoration.underline,
                ),
          ),
          if (showIcon) ...[
            const SizedBox(width: 4),
            Icon(
              icon ?? Icons.open_in_new,
              size: 16,
              color: color ?? Colors.blue,
            ),
          ],
        ],
      ),
    );
  }
}

/// Bouton avec lien externe
class ExternalLinkButton extends StatelessWidget {
  final String url;
  final String label;
  final IconData? icon;
  final bool isPrimary;

  const ExternalLinkButton({
    super.key,
    required this.url,
    required this.label,
    this.icon,
    this.isPrimary = false,
  });

  Future<void> _launchUrl(BuildContext context) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isPrimary) {
      return FilledButton.icon(
        onPressed: () => _launchUrl(context),
        icon: Icon(icon ?? Icons.open_in_new),
        label: Text(label),
      );
    }

    return OutlinedButton.icon(
      onPressed: () => _launchUrl(context),
      icon: Icon(icon ?? Icons.open_in_new),
      label: Text(label),
    );
  }
}