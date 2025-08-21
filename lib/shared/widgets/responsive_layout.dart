import 'package:flutter/material.dart';
import '../../core/utils/responsive_utils.dart';
import '../../core/constants/app_constants.dart';

/// Responsive layout wrapper that adjusts content based on screen size
class ResponsiveLayout extends StatelessWidget {
  const ResponsiveLayout({super.key, required this.child, this.maxWidth, this.padding});

  final Widget child;
  final double? maxWidth;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    final screenMaxWidth = maxWidth ?? ResponsiveUtils.getMaxContentWidth(context);
    final screenPadding = padding ?? ResponsiveUtils.responsivePadding(context);

    return Center(
      child: Container(
        width: screenMaxWidth == double.infinity ? null : screenMaxWidth,
        padding: screenPadding,
        child: SingleChildScrollView(child: child),
      ),
    );
  }
}

/// Responsive grid layout for form sections
class ResponsiveGrid extends StatelessWidget {
  const ResponsiveGrid({
    super.key,
    required this.children,
    this.spacing = AppConstants.spacingM,
    this.crossAxisSpacing,
    this.mainAxisSpacing,
  });

  final List<Widget> children;
  final double spacing;
  final double? crossAxisSpacing;
  final double? mainAxisSpacing;

  @override
  Widget build(BuildContext context) {
    if (ResponsiveUtils.isMobile(context)) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children.map((child) {
          final index = children.indexOf(child);
          return Padding(
            padding: EdgeInsets.only(bottom: index < children.length - 1 ? spacing : 0),
            child: child,
          );
        }).toList(),
      );
    }

    return Wrap(
      spacing: crossAxisSpacing ?? spacing,
      runSpacing: mainAxisSpacing ?? spacing,
      children: children.map((child) {
        return SizedBox(
          width:
              (MediaQuery.of(context).size.width -
                  (ResponsiveUtils.responsivePadding(context).horizontal) -
                  (crossAxisSpacing ?? spacing)) /
              2,
          child: child,
        );
      }).toList(),
    );
  }
}

/// Responsive card container
class ResponsiveCard extends StatelessWidget {
  const ResponsiveCard({super.key, required this.child, this.title, this.subtitle, this.actions, this.padding});

  final Widget child;
  final String? title;
  final String? subtitle;
  final List<Widget>? actions;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    final cardPadding =
        padding ??
        EdgeInsets.all(
          ResponsiveUtils.responsive(
            context,
            mobile: AppConstants.spacingM,
            tablet: AppConstants.spacingL,
            desktop: AppConstants.spacingXl,
          ),
        );

    return Card(
      child: Padding(
        padding: cardPadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title != null || actions != null) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (title != null)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(title!, style: Theme.of(context).textTheme.titleLarge),
                          if (subtitle != null) ...[
                            const SizedBox(height: AppConstants.spacingXs),
                            Text(
                              subtitle!,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  if (actions != null) Row(mainAxisSize: MainAxisSize.min, children: actions!),
                ],
              ),
              const SizedBox(height: AppConstants.spacingL),
            ],
            child,
          ],
        ),
      ),
    );
  }
}

/// Responsive form field wrapper
class ResponsiveFormField extends StatelessWidget {
  const ResponsiveFormField({
    super.key,
    required this.child,
    this.label,
    this.isRequired = false,
    this.helperText,
    this.flex = 1,
  });

  final Widget child;
  final String? label;
  final bool isRequired;
  final String? helperText;
  final int flex;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          RichText(
            text: TextSpan(
              text: label,
              style: Theme.of(context).textTheme.labelLarge,
              children: [
                if (isRequired)
                  TextSpan(
                    text: ' *',
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppConstants.spacingS),
        ],
        child,
        if (helperText != null) ...[
          const SizedBox(height: AppConstants.spacingXs),
          Text(
            helperText!,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
          ),
        ],
      ],
    );
  }
}

/// Responsive button row
class ResponsiveButtonRow extends StatelessWidget {
  const ResponsiveButtonRow({
    super.key,
    required this.children,
    this.spacing = AppConstants.spacingM,
    this.mainAxisAlignment = MainAxisAlignment.end,
  });

  final List<Widget> children;
  final double spacing;
  final MainAxisAlignment mainAxisAlignment;

  @override
  Widget build(BuildContext context) {
    if (ResponsiveUtils.isMobile(context)) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children.map((child) {
          final index = children.indexOf(child);
          return Padding(
            padding: EdgeInsets.only(bottom: index < children.length - 1 ? spacing : 0),
            child: child,
          );
        }).toList(),
      );
    }

    return Row(
      mainAxisAlignment: mainAxisAlignment,
      children: children.map((child) {
        final index = children.indexOf(child);
        return Padding(
          padding: EdgeInsets.only(left: index > 0 ? spacing : 0),
          child: child,
        );
      }).toList(),
    );
  }
}
