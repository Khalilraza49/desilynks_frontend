import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../app/theme.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_icons.dart';
import '../models/banner_ad_model.dart';
import 'custom_text_field.dart';

class BannerPositionDropdownField extends StatefulWidget {
  final BannerAdPosition selectedPosition;
  final ValueChanged<BannerAdPosition> onChanged;
  final Color? fillColor;
  final InputBorder? border;
  final InputBorder? enabledBorder;
  final InputBorder? focusedBorder;
  final BorderRadius? borderRadius;
  final double? maxDropdownHeight;

  const BannerPositionDropdownField({
    super.key,
    required this.selectedPosition,
    required this.onChanged,
    this.fillColor,
    this.border,
    this.enabledBorder,
    this.focusedBorder,
    this.borderRadius,
    this.maxDropdownHeight,
  });

  @override
  State<BannerPositionDropdownField> createState() =>
      _BannerPositionDropdownFieldState();
}

class _BannerPositionDropdownFieldState
    extends State<BannerPositionDropdownField> {
  final FocusNode _focusNode = FocusNode();
  final GlobalKey _key = GlobalKey();
  final LayerLink _layerLink = LayerLink();
  late TextEditingController _controller;
  OverlayEntry? _overlayEntry;
  bool _isMenuOpen = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.selectedPosition.dropdownLabel,
    );
  }

  @override
  void didUpdateWidget(covariant BannerPositionDropdownField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedPosition != widget.selectedPosition) {
      _controller.text = widget.selectedPosition.dropdownLabel;
    }
  }

  @override
  void dispose() {
    _overlayEntry?.remove();
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _toggleDropdown() {
    if (_isMenuOpen) {
      _closeDropdown();
    } else {
      _openDropdown();
    }
  }

  void _openDropdown() {
    _focusNode.requestFocus();
    final RenderBox? renderBox =
        _key.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    final Size size = renderBox.size;

    _overlayEntry = _createOverlayEntry(size);
    Overlay.of(context).insert(_overlayEntry!);
    setState(() {
      _isMenuOpen = true;
    });
  }

  void _closeDropdown() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    setState(() {
      _isMenuOpen = false;
    });
    _focusNode.unfocus();
  }

  OverlayEntry _createOverlayEntry(Size size) {
    return OverlayEntry(
      builder: (context) {
        return Stack(
          children: [
            GestureDetector(
              onTap: _closeDropdown,
              behavior: HitTestBehavior.translucent,
              child: Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.transparent,
              ),
            ),
            CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              offset: Offset(0, size.height - 1.5),
              child: Material(
                elevation: 0,
                color: Colors.transparent,
                child: Container(
                  width: size.width,
                  constraints: BoxConstraints(
                    maxHeight: widget.maxDropdownHeight ?? 180.0,
                  ),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      left: BorderSide(color: AppTheme.primaryBlue, width: 1.5),
                      right: BorderSide(
                        color: AppTheme.primaryBlue,
                        width: 1.5,
                      ),
                      bottom: BorderSide(
                        color: AppTheme.primaryBlue,
                        width: 1.5,
                      ),
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(10.5),
                      bottomRight: Radius.circular(10.5),
                    ),
                    child: SingleChildScrollView(
                      physics: const ClampingScrollPhysics(),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: BannerAdPosition.values.map((
                          BannerAdPosition pos,
                        ) {
                          final bool isSelected =
                              pos == widget.selectedPosition;
                          final bool isLast =
                              pos == BannerAdPosition.values.last;
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _controller.text = pos.dropdownLabel;
                              });
                              widget.onChanged(pos);
                              _closeDropdown();
                            },
                            child: Container(
                              width: double.infinity,
                              height: 42.0,
                              alignment: Alignment.centerLeft,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12.0,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppTheme.primaryBlue
                                    : Colors.transparent,
                                borderRadius: isSelected && isLast
                                    ? const BorderRadius.only(
                                        bottomLeft: Radius.circular(10.5),
                                        bottomRight: Radius.circular(10.5),
                                      )
                                    : null,
                              ),
                              child: Text(
                                pos.dropdownLabel,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 14.5,
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.black87,
                                  fontFamily: 'Inter',
                                  decoration: TextDecoration.none,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: CustomTextField(
        key: _key,
        controller: _controller,
        focusNode: _focusNode,
        readOnly: true,
        hintText: 'Select Position',
        textColor: _controller.text.isEmpty
            ? AppColors.gray500
            : Colors.black87,
        suffixIcon: SvgPicture.asset(
          AppIcons.arrowDropDownSvg,
          width: 14,
          height: 14,
          fit: BoxFit.scaleDown,
          colorFilter: const ColorFilter.mode(
            AppColors.svgDefault,
            BlendMode.srcIn,
          ),
        ),
        fillColor: widget.fillColor ?? Colors.white,
        border: widget.border,
        borderRadius: widget.borderRadius,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        focusedBorder:
            widget.focusedBorder ??
            OutlineInputBorder(
              borderRadius: _isMenuOpen
                  ? const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    )
                  : BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppTheme.primaryBlue,
                width: 1.5,
              ),
            ),
        enabledBorder:
            widget.enabledBorder ??
            OutlineInputBorder(
              borderRadius: _isMenuOpen
                  ? const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    )
                  : BorderRadius.circular(12),
              borderSide: BorderSide(
                color: _isMenuOpen
                    ? AppTheme.primaryBlue
                    : AppTheme.borderLight,
                width: 1.0,
              ),
            ),
        onTap: _toggleDropdown,
      ),
    );
  }
}
