import 'package:flutter/material.dart';

/// Avatar utilisateur avec initiales ou image
class UserAvatar extends StatelessWidget {
  final String userId;
  final String? imageUrl;
  final String name;
  final double size;
  final VoidCallback? onTap;
  final bool showBadge;
  final Color? badgeColor;
  final Color? backgroundColor;

  const UserAvatar({
    super.key,
    required this.userId,
    this.imageUrl,
    required this.name,
    this.size = 40,
    this.onTap,
    this.showBadge = false,
    this.badgeColor,
    this.backgroundColor,
  });

  String _getInitials(String name) {
    try {
      final trimmed = name.trim();
      if (trimmed.isEmpty) return '?';

      final parts = trimmed.split(' ').where((p) => p.isNotEmpty).toList();

      if (parts.isEmpty) return '?';
      if (parts.length == 1) {
        return parts[0].isNotEmpty ? parts[0][0].toUpperCase() : '?';
      }

      final first = parts.first.isNotEmpty ? parts.first[0] : '';
      final last = parts.last.isNotEmpty ? parts.last[0] : '';
      return '$first$last'.toUpperCase();
    } catch (e) {
      return '?';
    }
  }

  Color _getColorFromName(String name) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.pink,
      Colors.teal,
      Colors.indigo,
      Colors.cyan,
    ];

    try {
      if (name.isEmpty) return colors[0];
      final hash = name.codeUnits.fold(0, (prev, curr) => prev + curr);
      return colors[hash % colors.length];
    } catch (e) {
      return colors[0];
    }
  }

  @override
  Widget build(BuildContext context) {
    final avatar = Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: backgroundColor ?? _getColorFromName(name),
            image: imageUrl != null && imageUrl!.isNotEmpty
                ? DecorationImage(
              image: NetworkImage(imageUrl!),
              fit: BoxFit.cover,
              onError: (exception, stackTrace) {
                // Ignore l'erreur et affiche les initiales
              },
            )
                : null,
          ),
          child: imageUrl == null || imageUrl!.isEmpty
              ? Center(
            child: Text(
              _getInitials(name),
              style: TextStyle(
                color: Colors.white,
                fontSize: size * 0.4,
                fontWeight: FontWeight.bold,
              ),
            ),
          )
              : null,
        ),
        if (showBadge)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: size * 0.25,
              height: size * 0.25,
              decoration: BoxDecoration(
                color: badgeColor ?? Colors.green,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 2,
                ),
              ),
            ),
          ),
      ],
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(size / 2),
        child: avatar,
      );
    }

    return avatar;
  }
}

/// Avatar avec nom et rôle
class UserAvatarWithInfo extends StatelessWidget {
  final String? imageUrl;
  final String userId;
  final String name;
  final String? subtitle;
  final double avatarSize;
  final VoidCallback? onTap;
  final bool showOnlineStatus;

  const UserAvatarWithInfo({
    super.key,
    required this.userId,
    this.imageUrl,
    required this.name,
    this.subtitle,
    this.avatarSize = 48,
    this.onTap,
    this.showOnlineStatus = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(
          children: [
            UserAvatar(
              userId: userId,
              imageUrl: imageUrl,
              name: name,
              size: avatarSize,
              showBadge: showOnlineStatus,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name.isNotEmpty ? name : 'Utilisateur',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (subtitle != null && subtitle!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Liste d'avatars empilés
class AvatarStack extends StatelessWidget {
  final List<String> userIds;
  final List<String> names;
  final List<String?>? imageUrls;
  final double size;
  final int maxAvatars;
  final VoidCallback? onTap;

  const AvatarStack({
    super.key,
    required this.userIds,
    required this.names,
    this.imageUrls,
    this.size = 32,
    this.maxAvatars = 3,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (names.isEmpty) {
      return const SizedBox.shrink();
    }

    final displayCount = names.length > maxAvatars ? maxAvatars : names.length;
    final remainingCount = names.length - displayCount;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(size / 2),
      child: SizedBox(
        width: size + (displayCount - 1) * (size * 0.6) + (remainingCount > 0 ? size * 0.6 : 0),
        height: size,
        child: Stack(
          children: [
            ...List.generate(displayCount, (index) {
              return Positioned(
                left: index * (size * 0.6),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: UserAvatar(
                    userId: index < userIds.length ? userIds[index] : '?',
                    imageUrl: imageUrls != null && index < imageUrls!.length
                        ? imageUrls![index]
                        : null,
                    name: index < names.length ? names[index] : '?',
                    size: size,
                  ),
                ),
              );
            }),
            if (remainingCount > 0)
              Positioned(
                left: displayCount * (size * 0.6),
                child: Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Center(
                    child: Text(
                      '+$remainingCount',
                      style: TextStyle(
                        fontSize: size * 0.35,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Avatar cliquable avec menu
class UserAvatarMenu extends StatelessWidget {
  final String userId;
  final String? imageUrl;
  final String name;
  final String? email;
  final double size;
  final List<PopupMenuEntry<String>> menuItems;
  final Function(String) onMenuItemSelected;

  const UserAvatarMenu({
    super.key,
    required this.userId,
    this.imageUrl,
    required this.name,
    this.email,
    this.size = 40,
    required this.menuItems,
    required this.onMenuItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: onMenuItemSelected,
      itemBuilder: (context) => menuItems,
      offset: const Offset(0, 56),
      child: UserAvatar(
        userId: userId,
        imageUrl: imageUrl,
        name: name.isNotEmpty ? name : 'User',
        size: size,
      ),
    );
  }
}
/*
/// Widget helper pour tester les avatars
class AvatarShowcase extends StatelessWidget {
  const AvatarShowcase({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Avatar Showcase')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Avatar Simple:', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            children: const [
              UserAvatar(userId: 123456, name: 'John Doe', size: 48),
              SizedBox(width: 16),
              UserAvatar(name: 'Jane Smith', size: 48, showBadge: true),
              SizedBox(width: 16),
              UserAvatar(name: 'A', size: 48),
            ],
          ),
          const SizedBox(height: 32),

          const Text('Avatar avec Info:', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const UserAvatarWithInfo(
            name: 'John Doe',
            subtitle: 'Étudiant',
            showOnlineStatus: true,
          ),
          const SizedBox(height: 32),

          const Text('Avatar Stack:', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          AvatarStack(
            names: const ['Alice', 'Bob', 'Charlie', 'David', 'Eve'],
            maxAvatars: 3,
          ),
        ],
      ),
    );
  }
}*/