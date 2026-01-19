import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../cv_builder/data/services/firestore_cv_service.dart';

/// Modern CV list item widget with hover effects and animations
class CVListItem extends StatefulWidget {
  final CVMetadata metadata;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onDuplicate;

  const CVListItem({
    super.key,
    required this.metadata,
    required this.onTap,
    required this.onDelete,
    required this.onDuplicate,
  });

  @override
  State<CVListItem> createState() => _CVListItemState();
}

class _CVListItemState extends State<CVListItem>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1,
      end: 1.02,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _elevationAnimation = Tween<double>(
      begin: 2,
      end: 12,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onHover(bool isHovered) {
    setState(() => _isHovered = isHovered);
    if (isHovered) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('dd MMM yyyy', 'tr');

    return MouseRegion(
      onEnter: (_) => _onHover(true),
      onExit: (_) => _onHover(false),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(AppConstants.radiusL),
                border: Border.all(
                  color: _isHovered
                      ? theme.colorScheme.primary.withValues(alpha: 0.3)
                      : theme.colorScheme.outline.withValues(alpha: 0.1),
                  width: _isHovered ? 2 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _isHovered
                        ? theme.colorScheme.primary.withValues(alpha: 0.15)
                        : theme.colorScheme.shadow.withValues(alpha: 0.05),
                    blurRadius: _elevationAnimation.value,
                    offset: Offset(0, _elevationAnimation.value / 3),
                  ),
                ],
              ),
              child: child,
            ),
          );
        },
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(AppConstants.radiusL),
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.spacingL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // CV Icon with gradient
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              theme.colorScheme.primary,
                              theme.colorScheme.primary.withValues(alpha: 0.7),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: theme.colorScheme.primary.withValues(
                                alpha: 0.3,
                              ),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(
                          PhosphorIconsFill.fileText,
                          color: theme.colorScheme.onPrimary,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: AppConstants.spacingM),

                      // Title and info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.metadata.title.isEmpty
                                  ? AppLocalizations.of(context)!.newCV
                                  : widget.metadata.title,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  PhosphorIconsRegular.clock,
                                  size: 14,
                                  color: theme.colorScheme.onSurface.withValues(
                                    alpha: 0.5,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    _getTimeAgo(
                                      context,
                                      widget.metadata.updatedAt,
                                    ),
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurface
                                          .withValues(alpha: 0.6),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Menu button
                      _buildMenuButton(theme),
                    ],
                  ),

                  const Spacer(),

                  // Footer
                  Row(
                    children: [
                      // Creation date
                      Expanded(
                        child: Row(
                          children: [
                            Icon(
                              PhosphorIconsRegular.calendar,
                              size: 14,
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.4,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              dateFormat.format(widget.metadata.createdAt),
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onSurface.withValues(
                                  alpha: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Quick actions (visible on hover)
                      AnimatedOpacity(
                        duration: AppConstants.animationFast,
                        opacity: _isHovered ? 1.0 : 0.0,
                        child: Row(
                          children: [
                            _buildQuickAction(
                              theme,
                              PhosphorIconsRegular.pencil,
                              AppLocalizations.of(context)!.editButton,
                              widget.onTap,
                            ),
                            const SizedBox(width: 8),
                            _buildQuickAction(
                              theme,
                              PhosphorIconsRegular.copy,
                              AppLocalizations.of(context)!.copyButton,
                              widget.onDuplicate,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAction(
    ThemeData theme,
    IconData icon,
    String tooltip,
    VoidCallback onTap,
  ) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: theme.colorScheme.primary),
        ),
      ),
    );
  }

  Widget _buildMenuButton(ThemeData theme) {
    return PopupMenuButton<String>(
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: _isHovered
              ? theme.colorScheme.primary.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          PhosphorIconsRegular.dotsThreeVertical,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          size: 20,
        ),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
      ),
      onSelected: (value) {
        switch (value) {
          case 'edit':
            widget.onTap();
            break;
          case 'duplicate':
            widget.onDuplicate();
            break;
          case 'delete':
            widget.onDelete();
            break;
        }
      },
      itemBuilder: (context) {
        final l10n = AppLocalizations.of(context)!;
        return [
          _buildMenuItem(
            context,
            'edit',
            PhosphorIconsRegular.pencil,
            l10n.editButton,
          ),
          _buildMenuItem(
            context,
            'duplicate',
            PhosphorIconsRegular.copy,
            l10n.copyButton,
          ),
          const PopupMenuDivider(),
          _buildMenuItem(
            context,
            'delete',
            PhosphorIconsRegular.trash,
            l10n.deleteButton,
            isDestructive: true,
          ),
        ];
      },
    );
  }

  PopupMenuItem<String> _buildMenuItem(
    BuildContext context,
    String value,
    IconData icon,
    String label, {
    bool isDestructive = false,
  }) {
    final theme = Theme.of(context);
    final color = isDestructive ? Colors.red : theme.colorScheme.onSurface;

    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 12),
          Text(label, style: TextStyle(color: color)),
        ],
      ),
    );
  }

  String _getTimeAgo(BuildContext context, DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    final l10n = AppLocalizations.of(context)!;

    if (difference.inDays > 30) {
      return DateFormat('dd MMM').format(dateTime);
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ${l10n.daysAgo}';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${l10n.hoursAgo}';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${l10n.minutesAgo}';
    } else {
      return l10n.justNow;
    }
  }
}
