import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'responsive_text.dart';

class AppAnimatedDropdown<T> extends StatefulWidget {
  final String label;
  final String hint;
  final T? value;
  final List<T> items;
  final String Function(T) itemLabel;
  final IconData? prefixIcon;
  final ValueChanged<T?> onChanged;
  final String? Function(T?)? validator;
  final bool isRequired;
  final String sheetTitle;
  final bool showSearch;
  final Color? accentColor;
  final Color? fillColor;

  const AppAnimatedDropdown({
    super.key,
    required this.label,
    required this.hint,
    required this.value,
    required this.items,
    required this.itemLabel,
    required this.onChanged,
    this.prefixIcon,
    this.validator,
    this.isRequired = false,
    this.sheetTitle = 'Select Option',
    this.showSearch = false,
    this.accentColor,
    this.fillColor,
  });

  @override
  State<AppAnimatedDropdown<T>> createState() => _AppAnimatedDropdownState<T>();
}

class _AppAnimatedDropdownState<T> extends State<AppAnimatedDropdown<T>>
    with SingleTickerProviderStateMixin {
  // ── BRAND PALETTE ──────────────────────────────────────────────────────────
  Color get primaryAccent => widget.accentColor ?? const Color(0xFF4B96E6);
  static const Color textDark = Color(0xFF0F172A);
  static const Color textMuted = Color(0xFF64748B);
  static const Color subtleBorder = Color(0xFFE2E8F0);
  static const Color errorRed = Color(0xFFEF4444);

  final LayerLink _layerLink = LayerLink();
  final GlobalKey _triggerKey = GlobalKey();
  OverlayEntry? _overlayEntry;
  bool _isOpen = false;

  late AnimationController _arrowController;
  late Animation<double> _arrowAnimation;

  @override
  void initState() {
    super.initState();
    _arrowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    // 0.0 -> 0.5 rotates 180 degrees
    _arrowAnimation = Tween<double>(begin: 0.0, end: 0.5).animate(
      CurvedAnimation(parent: _arrowController, curve: Curves.easeInOutCubic),
    );
  }

  @override
  void dispose() {
    _removeOverlay(notify: false);
    _arrowController.dispose();
    super.dispose();
  }

  void _toggleDropdown(FormFieldState<T> formState) {
    HapticFeedback.selectionClick();
    if (_isOpen) {
      _closeDropdown();
    } else {
      _openDropdown(formState);
    }
  }

  void _openDropdown(FormFieldState<T> formState) {
    final renderBox =
        _triggerKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final triggerSize = renderBox.size;
    final triggerOffset = renderBox.localToGlobal(Offset.zero);
    final screenSize = MediaQuery.of(context).size;
    final spaceBelow =
        screenSize.height - (triggerOffset.dy + triggerSize.height);
    final bool openUpwards = spaceBelow < 220 && triggerOffset.dy > 220;
    final double cardMaxHeight = (openUpwards
            ? triggerOffset.dy - 30
            : spaceBelow - 30)
        .clamp(140.0, 270.0);
    final overlay = Overlay.of(context);

    _arrowController.forward();
    setState(() => _isOpen = true);

    _overlayEntry = OverlayEntry(
      builder: (context) {
        return Stack(
          children: [
            // Full-screen translucent barrier to detect outside clicks
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: _closeDropdown,
              ),
            ),

            // Dropdown menu card anchored directly relative to trigger box
            CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              offset: Offset(
                0,
                openUpwards
                    ? -(cardMaxHeight + 6)
                    : (triggerSize.height + 6),
              ),
              child: Material(
                color: Colors.transparent,
                child: _DropdownOverlayCard<T>(
                  width: triggerSize.width,
                  maxHeight: cardMaxHeight,
                  items: widget.items,
                  selectedValue: widget.value,
                  itemLabel: widget.itemLabel,
                  accentColor: primaryAccent,
                  showSearch: widget.showSearch || widget.items.length > 6,
                  onSelected: (val) {
                    widget.onChanged(val);
                    formState.didChange(val);
                    _closeDropdown();
                  },
                ),
              ),
            ),
          ],
        );
      },
    );

    overlay.insert(_overlayEntry!);
  }

  void _closeDropdown() {
    if (!_isOpen && _overlayEntry == null) return;
    _arrowController.reverse();
    _removeOverlay(notify: true);
  }

  void _removeOverlay({bool notify = true}) {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _isOpen = false;
    if (notify && mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return FormField<T>(
      initialValue: widget.value,
      validator: widget.validator,
      builder: (formState) {
        final bool hasError = formState.hasError;
        final bool hasValue = widget.value != null;
        final String displayText =
            hasValue ? widget.itemLabel(widget.value as T) : widget.hint;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Top Field Label ──
            if (widget.label.isNotEmpty) ...[
              Row(
                children: [
                  ResponsiveText(
                    widget.label,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: textDark,
                  ),
                  if (widget.isRequired) ...[
                    const SizedBox(width: 4),
                    const Text(
                      '*',
                      style: TextStyle(
                        color: errorRed,
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 7),
            ],

            // ── Clean Modern Dropdown Trigger Box ──
            CompositedTransformTarget(
              link: _layerLink,
              child: Container(
                key: _triggerKey,
                child: InkWell(
                  onTap: () => _toggleDropdown(formState),
                  borderRadius: BorderRadius.circular(16),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: widget.fillColor ?? Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: hasError
                            ? errorRed
                            : (_isOpen
                                ? primaryAccent
                                : subtleBorder),
                        width: (_isOpen || hasError) ? 1.8 : 1.2,
                      ),
                      boxShadow: [
                        if (_isOpen)
                          BoxShadow(
                            color: primaryAccent.withValues(alpha: 0.15),
                            blurRadius: 12,
                            offset: const Offset(0, 3),
                          )
                        else
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // Prefix Icon Pill
                        if (widget.prefixIcon != null) ...[
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: _isOpen
                                  ? primaryAccent.withValues(alpha: 0.12)
                                  : const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              widget.prefixIcon,
                              color: primaryAccent,
                              size: 17,
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],

                        // Main Text Display
                        Expanded(
                          child: Text(
                            displayText,
                            style: TextStyle(
                              fontSize: 14.5,
                              fontWeight:
                                  hasValue ? FontWeight.w700 : FontWeight.w500,
                              color: hasValue ? textDark : textMuted,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Rotating Chevron Badge
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: _isOpen
                                ? primaryAccent.withValues(alpha: 0.1)
                                : const Color(0xFFF8FAFC),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: RotationTransition(
                              turns: _arrowAnimation,
                              child: Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color: _isOpen ? primaryAccent : textMuted,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            if (hasError && formState.errorText != null) ...[
              const SizedBox(height: 5),
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: ResponsiveText(
                  formState.errorText!,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: errorRed,
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

// ── FLOATING DROPDOWN OVERLAY CARD ──────────────────────────────────────────
class _DropdownOverlayCard<T> extends StatefulWidget {
  final double width;
  final double maxHeight;
  final List<T> items;
  final T? selectedValue;
  final String Function(T) itemLabel;
  final bool showSearch;
  final Color accentColor;
  final ValueChanged<T> onSelected;

  const _DropdownOverlayCard({
    required this.width,
    this.maxHeight = 260.0,
    required this.items,
    required this.selectedValue,
    required this.itemLabel,
    required this.showSearch,
    required this.accentColor,
    required this.onSelected,
  });

  @override
  State<_DropdownOverlayCard<T>> createState() =>
      _DropdownOverlayCardState<T>();
}

class _DropdownOverlayCardState<T> extends State<_DropdownOverlayCard<T>>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<T> _filteredItems = [];

  late AnimationController _animController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _filteredItems = widget.items;

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );

    _animController.forward();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _filterItems(String query) {
    if (query.trim().isEmpty) {
      setState(() => _filteredItems = widget.items);
    } else {
      setState(() {
        _filteredItems = widget.items
            .where((item) => widget
                .itemLabel(item)
                .toLowerCase()
                .contains(query.trim().toLowerCase()))
            .toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedBg = widget.accentColor.withValues(alpha: 0.1);

    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        alignment: Alignment.topCenter,
        child: Container(
          width: widget.width,
          constraints: BoxConstraints(maxHeight: widget.maxHeight),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: widget.accentColor.withValues(alpha: 0.06),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Optional Search Input ──
              if (widget.showSearch) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _filterItems,
                    style: const TextStyle(
                      fontSize: 13.5,
                      color: Color(0xFF0F172A),
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: InputDecoration(
                      isDense: true,
                      hintText: 'Search options...',
                      hintStyle: const TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 13,
                      ),
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        size: 18,
                        color: widget.accentColor,
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded,
                                  size: 16, color: Color(0xFF94A3B8)),
                              onPressed: () {
                                _searchController.clear();
                                _filterItems('');
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                            color: widget.accentColor, width: 1.5),
                      ),
                    ),
                  ),
                ),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
              ],

              // ── Items List with Modern Scroll Indicator ──
              Flexible(
                child: _filteredItems.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Center(
                          child: Text(
                            'No matching options found',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                        ),
                      )
                    : RawScrollbar(
                        controller: _scrollController,
                        thumbVisibility: true,
                        thickness: 4.5,
                        radius: const Radius.circular(4),
                        thumbColor: widget.accentColor.withValues(alpha: 0.6),
                        padding: const EdgeInsets.only(
                            right: 4, top: 6, bottom: 6),
                        child: ListView.builder(
                          controller: _scrollController,
                          shrinkWrap: true,
                          padding: const EdgeInsets.symmetric(
                              vertical: 6, horizontal: 6),
                          itemCount: _filteredItems.length,
                          itemBuilder: (context, index) {
                            final item = _filteredItems[index];
                            final bool isSelected =
                                widget.selectedValue == item;
                            final String label = widget.itemLabel(item);

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 2),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    HapticFeedback.lightImpact();
                                    widget.onSelected(item);
                                  },
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 11),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? selectedBg
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            label,
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: isSelected
                                                  ? FontWeight.w700
                                                  : FontWeight.w600,
                                              color: isSelected
                                                  ? widget.accentColor
                                                  : const Color(0xFF1E293B),
                                            ),
                                          ),
                                        ),
                                        if (isSelected)
                                          Container(
                                            width: 20,
                                            height: 20,
                                            decoration: BoxDecoration(
                                              color: widget.accentColor,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Center(
                                              child: Icon(
                                                Icons.check_rounded,
                                                size: 13,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
