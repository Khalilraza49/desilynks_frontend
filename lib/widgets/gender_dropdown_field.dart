import 'package:desilynks/core/constants/app_colors.dart';
import 'package:desilynks/core/constants/app_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../app/theme.dart';
import 'custom_text_field.dart';

class GenderDropdownField extends StatefulWidget {
  final TextEditingController controller;
  final ValueChanged<String?> onChanged;
  final Color? fillColor;
  final InputBorder? border;
  final InputBorder? enabledBorder;
  final InputBorder? focusedBorder;
  final BorderRadius? borderRadius;
  final double? maxDropdownHeight;

  const GenderDropdownField({
    super.key,
    required this.controller,
    required this.onChanged,
    this.fillColor,
    this.border,
    this.enabledBorder,
    this.focusedBorder,
    this.borderRadius,
    this.maxDropdownHeight,
  });

  @override
  State<GenderDropdownField> createState() => _GenderDropdownFieldState();
}

class _GenderDropdownFieldState extends State<GenderDropdownField> {
  final _genderFocusNode = FocusNode();
  final GlobalKey _genderKey = GlobalKey();
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool _isMenuOpen = false;

  @override
  void dispose() {
    _overlayEntry?.remove();
    _genderFocusNode.dispose();
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
    _genderFocusNode.requestFocus();
    final RenderBox renderBox =
        _genderKey.currentContext!.findRenderObject() as RenderBox;
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
    _genderFocusNode.unfocus();
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
                  decoration: const BoxDecoration(color: Colors.white),
                  child: SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children:
                          [
                            'Select',
                            'Male',
                            'Female',
                            'Prefer not to say',
                          ].map((String value) {
                            final bool isSelected =
                                value == widget.controller.text;
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  widget.controller.text = value;
                                });
                                widget.onChanged(value);
                                _closeDropdown();
                              },
                              child: Container(
                                width: double.infinity,
                                height: 40.0,
                                alignment: Alignment.centerLeft,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10.0,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppTheme.primaryBlue
                                      : Colors.transparent,
                                  borderRadius:
                                      isSelected && value == 'Prefer not to say'
                                      ? const BorderRadius.only(
                                          bottomLeft: Radius.circular(10.5),
                                          bottomRight: Radius.circular(10.5),
                                        )
                                      : null,
                                ),
                                child: Text(
                                  value,
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: isSelected
                                        ? Colors.white
                                        : (value == 'Select'
                                              ? AppColors.slate400
                                              : Colors.black87),
                                    fontFamily: 'Inter',
                                    decoration: TextDecoration.none,
                                    fontWeight: FontWeight.normal,
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
        key: _genderKey,
        controller: widget.controller,
        focusNode: _genderFocusNode,
        readOnly: true,
        hintText: 'Select',
        textColor: widget.controller.text == 'Select'
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
        fillColor: widget.fillColor,
        border: widget.border,
        borderRadius: widget.borderRadius,
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
