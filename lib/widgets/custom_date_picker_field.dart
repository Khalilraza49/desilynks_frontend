import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_constants.dart';
import '../core/constants/app_icons.dart';
import 'custom_text_field.dart';

class CustomDatePickerField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final ValueChanged<DateTime>? onDateSelected;
  final Color? fillColor;
  final InputBorder? border;
  final InputBorder? enabledBorder;
  final InputBorder? focusedBorder;
  final BorderRadius? borderRadius;
  final FormFieldValidator<String>? validator;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final DateTime? initialDate;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool showSuffixIcon;
  final double? fontSize;
  final EdgeInsetsGeometry? padding;

  const CustomDatePickerField({
    super.key,
    required this.controller,
    this.hintText = 'mm/dd/yyyy',
    this.onDateSelected,
    this.fillColor,
    this.border,
    this.enabledBorder,
    this.focusedBorder,
    this.borderRadius,
    this.validator,
    this.firstDate,
    this.lastDate,
    this.initialDate,
    this.prefixIcon,
    this.suffixIcon,
    this.showSuffixIcon = true,
    this.fontSize,
    this.padding,
  });

  @override
  State<CustomDatePickerField> createState() => _CustomDatePickerFieldState();
}

class _CustomDatePickerFieldState extends State<CustomDatePickerField> {
  final FocusNode _focusNode = FocusNode();
  final GlobalKey _fieldKey = GlobalKey();
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool _isOpen = false;

  late int _viewYear;
  late int _viewMonth;
  DateTime? _selectedDate;
  bool _isYearPickerOpen = false;

  static const List<String> _monthNames = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  static const List<String> _weekDays = [
    'Su',
    'Mo',
    'Tu',
    'We',
    'Th',
    'Fr',
    'Sa',
  ];

  @override
  void initState() {
    super.initState();
    _initDate();
  }

  @override
  void didUpdateWidget(CustomDatePickerField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller ||
        oldWidget.controller.text != widget.controller.text) {
      _initDate();
    }
  }

  void _initDate() {
    final now = DateTime.now();
    final defaultDate = widget.initialDate ?? now;
    _viewYear = defaultDate.year;
    _viewMonth = defaultDate.month;

    final rawText = widget.controller.text.trim();
    if (rawText.isNotEmpty) {
      try {
        final parts = rawText.split('/');
        if (parts.length == 3) {
          final first = int.parse(parts[0]);
          final second = int.parse(parts[1]);
          int y = int.parse(parts[2]);
          if (y < 100) {
            y += (y > (now.year % 100)) ? 1900 : 2000;
          }
          final isDayFirst =
              widget.hintText.toLowerCase().startsWith('dd') || first > 12;
          final d = isDayFirst ? first : second;
          final m = isDayFirst ? second : first;
          _selectedDate = DateTime(y, m, d);
          _viewYear = y;
          _viewMonth = m;
        } else {
          final parsed = DateTime.tryParse(rawText);
          if (parsed != null) {
            _selectedDate = DateTime(parsed.year, parsed.month, parsed.day);
            _viewYear = parsed.year;
            _viewMonth = parsed.month;
            final isDayFirst =
                widget.hintText.toLowerCase().startsWith('dd');
            final formatted = isDayFirst
                ? "${parsed.day.toString().padLeft(2, '0')}/${parsed.month.toString().padLeft(2, '0')}/${parsed.year}"
                : "${parsed.month.toString().padLeft(2, '0')}/${parsed.day.toString().padLeft(2, '0')}/${parsed.year}";
            widget.controller.text = formatted;
          }
        }
      } catch (_) {}
    } else if (widget.firstDate != null) {
      final minDate = DateTime(
        widget.firstDate!.year,
        widget.firstDate!.month,
        widget.firstDate!.day,
      );
      if (DateTime(_viewYear, _viewMonth, 1).isBefore(minDate)) {
        _viewYear = widget.firstDate!.year;
        _viewMonth = widget.firstDate!.month;
      }
    }
  }

  @override
  void dispose() {
    _overlayEntry?.remove();
    _focusNode.dispose();
    super.dispose();
  }

  bool _isDateDisabled(int year, int month, int day) {
    final date = DateTime(year, month, day);
    if (widget.firstDate != null) {
      final minDate = DateTime(
        widget.firstDate!.year,
        widget.firstDate!.month,
        widget.firstDate!.day,
      );
      if (date.isBefore(minDate)) {
        return true;
      }
    }
    if (widget.lastDate != null) {
      final maxDate = DateTime(
        widget.lastDate!.year,
        widget.lastDate!.month,
        widget.lastDate!.day,
      );
      if (date.isAfter(maxDate)) {
        return true;
      }
    }
    return false;
  }

  bool get _canGoPreviousMonth {
    if (widget.firstDate == null) return true;
    final minMonth = DateTime(
      widget.firstDate!.year,
      widget.firstDate!.month,
      1,
    );
    final currentViewMonth = DateTime(_viewYear, _viewMonth, 1);
    return currentViewMonth.isAfter(minMonth);
  }

  bool get _canGoNextMonth {
    if (widget.lastDate == null) return true;
    final maxMonth = DateTime(widget.lastDate!.year, widget.lastDate!.month, 1);
    final currentViewMonth = DateTime(_viewYear, _viewMonth, 1);
    return currentViewMonth.isBefore(maxMonth);
  }

  void _toggleCalendar() {
    if (_isOpen) {
      _closeCalendar();
    } else {
      _openCalendar();
    }
  }

  void _openCalendar() {
    _focusNode.requestFocus();
    _initDate();
    _isYearPickerOpen = false;

    final RenderBox renderBox =
        _fieldKey.currentContext!.findRenderObject() as RenderBox;
    final Size size = renderBox.size;
    final Offset globalPos = renderBox.localToGlobal(Offset.zero);
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final screenWidth = mediaQuery.size.width;
    final spaceBelow = screenHeight - (globalPos.dy + size.height);
    final bool openUpwards = spaceBelow < 290;

    const double overlayWidth = 240.0;
    final double maxAllowedX = (screenWidth - overlayWidth - 12.0).clamp(
      12.0,
      double.infinity,
    );
    final double desiredX = globalPos.dx.clamp(12.0, maxAllowedX);
    final double offsetX = desiredX - globalPos.dx;

    _overlayEntry = _createOverlayEntry(
      size,
      openUpwards: openUpwards,
      offsetX: offsetX,
    );
    Overlay.of(context).insert(_overlayEntry!);
    setState(() {
      _isOpen = true;
    });
  }

  void _closeCalendar() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    if (mounted) {
      setState(() {
        _isOpen = false;
        _isYearPickerOpen = false;
      });
    }
    _focusNode.unfocus();
  }

  void _previousMonth() {
    if (!_canGoPreviousMonth) return;
    setState(() {
      if (_viewMonth == 1) {
        _viewMonth = 12;
        _viewYear--;
      } else {
        _viewMonth--;
      }
      _overlayEntry?.markNeedsBuild();
    });
  }

  void _nextMonth() {
    if (!_canGoNextMonth) return;
    setState(() {
      if (_viewMonth == 12) {
        _viewMonth = 1;
        _viewYear++;
      } else {
        _viewMonth++;
      }
      _overlayEntry?.markNeedsBuild();
    });
  }

  void _selectDay(int year, int month, int day) {
    if (_isDateDisabled(year, month, day)) return;
    final picked = DateTime(year, month, day);
    _selectedDate = picked;
    final isDayFirst = widget.hintText.toLowerCase().startsWith('dd');
    final formatted = isDayFirst
        ? "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}"
        : "${picked.month.toString().padLeft(2, '0')}/${picked.day.toString().padLeft(2, '0')}/${picked.year}";
    widget.controller.text = formatted;
    widget.onDateSelected?.call(picked);
    _closeCalendar();
  }

  void _clearDate() {
    _selectedDate = null;
    widget.controller.clear();
    _closeCalendar();
  }

  void _selectToday() {
    final now = DateTime.now();
    if (!_isDateDisabled(now.year, now.month, now.day)) {
      _selectDay(now.year, now.month, now.day);
    }
  }

  OverlayEntry _createOverlayEntry(
    Size size, {
    bool openUpwards = false,
    double offsetX = 0.0,
  }) {
    return OverlayEntry(
      builder: (context) {
        return Stack(
          children: [
            GestureDetector(
              onTap: _closeCalendar,
              behavior: HitTestBehavior.translucent,
              child: const SizedBox.expand(),
            ),
            CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              targetAnchor: openUpwards
                  ? Alignment.topLeft
                  : Alignment.bottomLeft,
              followerAnchor: openUpwards
                  ? Alignment.bottomLeft
                  : Alignment.topLeft,
              offset: Offset(offsetX, openUpwards ? -4 : 4),
              child: Material(
                elevation: 10,
                shadowColor: Colors.black.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(8),
                color: Colors.white,
                child: Container(
                  width: 240,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: StatefulBuilder(
                    builder: (context, setOverlayState) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Header: Month Year with dropdown + Up/Down arrows
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  setOverlayState(() {
                                    _isYearPickerOpen = !_isYearPickerOpen;
                                  });
                                },
                                behavior: HitTestBehavior.opaque,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '${_monthNames[_viewMonth - 1]} $_viewYear',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.black87,
                                        fontFamily: 'Inter',
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    SvgPicture.asset(
                                      AppIcons.arrowDropDownSvg,
                                      width: 14,
                                      height: 14,
                                      colorFilter: const ColorFilter.mode(
                                        Colors.black87,
                                        BlendMode.srcIn,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  GestureDetector(
                                    onTap: _canGoPreviousMonth
                                        ? () {
                                            _previousMonth();
                                            setOverlayState(() {});
                                          }
                                        : null,
                                    child: Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: SvgPicture.asset(
                                        AppIcons.calLeftArrow,
                                        width: 20,
                                        height: 20,
                                        colorFilter: ColorFilter.mode(
                                          _canGoPreviousMonth
                                              ? Colors.black87
                                              : const Color(0xFFD1D5DB),
                                          BlendMode.srcIn,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 2),
                                  GestureDetector(
                                    onTap: _canGoNextMonth
                                        ? () {
                                            _nextMonth();
                                            setOverlayState(() {});
                                          }
                                        : null,
                                    child: Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: SvgPicture.asset(
                                        AppIcons.rightarrow,
                                        width: 20,
                                        height: 20,
                                        colorFilter: ColorFilter.mode(
                                          _canGoNextMonth
                                              ? Colors.black87
                                              : const Color(0xFFD1D5DB),
                                          BlendMode.srcIn,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),

                          // If year/month picker mode is toggled
                          if (_isYearPickerOpen)
                            _buildYearMonthPicker(setOverlayState)
                          else ...[
                            // Day of week headers: Su Mo Tu We Th Fr Sa
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: _weekDays.map((day) {
                                return Expanded(
                                  child: Center(
                                    child: Text(
                                      day,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                        fontFamily: 'Inter',
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 6),

                            // Calendar Grid
                            _buildDaysGrid(),
                          ],

                          const SizedBox(height: 8),
                          const Divider(height: 1, color: Color(0xFFE5E7EB)),
                          const SizedBox(height: 4),

                          // Bottom Actions: Clear (left) and Today (right)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                onTap: _clearDate,
                                behavior: HitTestBehavior.opaque,
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(
                                    vertical: 4,
                                    horizontal: 2,
                                  ),
                                  child: Text(
                                    'Clear',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF2563EB),
                                      fontFamily: 'Inter',
                                    ),
                                  ),
                                ),
                              ),
                              Builder(
                                builder: (context) {
                                  final now = DateTime.now();
                                  final isTodayDisabled = _isDateDisabled(
                                    now.year,
                                    now.month,
                                    now.day,
                                  );
                                  return GestureDetector(
                                    onTap: isTodayDisabled
                                        ? null
                                        : _selectToday,
                                    behavior: HitTestBehavior.opaque,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 4,
                                        horizontal: 2,
                                      ),
                                      child: Text(
                                        'Today',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: isTodayDisabled
                                              ? const Color(0xFF9CA3AF)
                                              : const Color(0xFF2563EB),
                                          fontFamily: 'Inter',
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildYearMonthPicker(StateSetter setOverlayState) {
    final currentYear = DateTime.now().year;
    final minYear = widget.firstDate?.year ?? (currentYear - 100);
    final maxYear = widget.lastDate?.year ?? (currentYear + 50);
    final yearsCount = (maxYear - minYear) + 1;

    return SizedBox(
      height: 180,
      child: Column(
        children: [
          // Quick year selector
          Expanded(
            child: ListView.builder(
              itemCount: yearsCount > 0 ? yearsCount : 1,
              itemBuilder: (context, index) {
                final year = maxYear >= minYear ? maxYear - index : minYear;
                final isSelectedYear = year == _viewYear;
                return GestureDetector(
                  onTap: () {
                    setOverlayState(() {
                      _viewYear = year;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    alignment: Alignment.center,
                    color: isSelectedYear
                        ? const Color(0xFFE5E7EB)
                        : Colors.transparent,
                    child: Text(
                      '$year',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelectedYear
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: isSelectedYear
                            ? const Color(0xFF2563EB)
                            : Colors.black87,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1),
          // Months horizontal / grid
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: List.generate(12, (index) {
              final month = index + 1;
              final isSelectedMonth = month == _viewMonth;

              final lastDayOfMonth = DateTime(_viewYear, month + 1, 0);
              final firstDayOfMonth = DateTime(_viewYear, month, 1);
              final isMonthDisabled =
                  (widget.firstDate != null &&
                      lastDayOfMonth.isBefore(
                        DateTime(
                          widget.firstDate!.year,
                          widget.firstDate!.month,
                          widget.firstDate!.day,
                        ),
                      )) ||
                  (widget.lastDate != null &&
                      firstDayOfMonth.isAfter(
                        DateTime(
                          widget.lastDate!.year,
                          widget.lastDate!.month,
                          widget.lastDate!.day,
                        ),
                      ));

              return GestureDetector(
                onTap: isMonthDisabled
                    ? null
                    : () {
                        setOverlayState(() {
                          _viewMonth = month;
                          _isYearPickerOpen = false;
                        });
                      },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: isSelectedMonth
                        ? const Color(0xFF2563EB)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _monthNames[index].substring(0, 3),
                    style: TextStyle(
                      fontSize: 10,
                      color: isMonthDisabled
                          ? const Color(0xFFD1D5DB)
                          : isSelectedMonth
                          ? Colors.white
                          : Colors.black87,
                      fontWeight: isSelectedMonth
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildDaysGrid() {
    final firstDayOfMonth = DateTime(_viewYear, _viewMonth, 1);
    final startOffset = firstDayOfMonth.weekday % 7; // Sunday = 0
    final daysInPrevMonth = DateTime(_viewYear, _viewMonth, 0).day;
    final daysInCurrentMonth = DateTime(_viewYear, _viewMonth + 1, 0).day;

    final List<Widget> dayWidgets = [];

    // Prev month overflow days
    for (int i = 0; i < startOffset; i++) {
      final day = daysInPrevMonth - startOffset + 1 + i;
      final prevMonth = _viewMonth == 1 ? 12 : _viewMonth - 1;
      final prevYear = _viewMonth == 1 ? _viewYear - 1 : _viewYear;
      dayWidgets.add(_buildDayCell(prevYear, prevMonth, day, isOverflow: true));
    }

    // Current month days
    for (int day = 1; day <= daysInCurrentMonth; day++) {
      dayWidgets.add(
        _buildDayCell(_viewYear, _viewMonth, day, isOverflow: false),
      );
    }

    // Next month overflow days
    final totalCells = dayWidgets.length;
    final remaining = (7 - (totalCells % 7)) % 7;
    for (int day = 1; day <= remaining; day++) {
      final nextMonth = _viewMonth == 12 ? 1 : _viewMonth + 1;
      final nextYear = _viewMonth == 12 ? _viewYear + 1 : _viewYear;
      dayWidgets.add(_buildDayCell(nextYear, nextMonth, day, isOverflow: true));
    }

    // Split into rows of 7
    final List<Widget> rows = [];
    for (int i = 0; i < dayWidgets.length; i += 7) {
      final rowDays = dayWidgets.sublist(
        i,
        (i + 7 > dayWidgets.length) ? dayWidgets.length : i + 7,
      );
      rows.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 2.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: rowDays.map((w) => Expanded(child: w)).toList(),
          ),
        ),
      );
    }

    return Column(mainAxisSize: MainAxisSize.min, children: rows);
  }

  Widget _buildDayCell(
    int year,
    int month,
    int day, {
    required bool isOverflow,
  }) {
    final isSelected =
        _selectedDate != null &&
        _selectedDate!.year == year &&
        _selectedDate!.month == month &&
        _selectedDate!.day == day;
    final isDisabled = _isDateDisabled(year, month, day);

    return GestureDetector(
      onTap: isDisabled ? null : () => _selectDay(year, month, day),
      behavior: isDisabled
          ? HitTestBehavior.deferToChild
          : HitTestBehavior.opaque,
      child: Center(
        child: Container(
          width: 24,
          height: 24,
          alignment: Alignment.center,
          decoration: isSelected
              ? BoxDecoration(
                  color: const Color(0xFF6B7280),
                  borderRadius: BorderRadius.circular(2),
                  border: Border.all(color: Colors.black, width: 1.8),
                )
              : null,
          child: Text(
            '$day',
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected
                  ? Colors.white
                  : isDisabled
                  ? const Color(0xFFD1D5DB)
                  : (isOverflow
                        ? const Color(0xFF9CA3AF)
                        : const Color(0xFF111827)),
              fontFamily: 'Inter',
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        key: _fieldKey,
        onTap: _toggleCalendar,
        behavior: HitTestBehavior.opaque,
        child: AbsorbPointer(
          child: CustomTextField(
            controller: widget.controller,
            focusNode: _focusNode,
            hintText: widget.hintText,
            fontSize: widget.fontSize,
            padding: widget.padding,
            readOnly: true,
            fillColor: widget.fillColor,
            border: widget.border,
            enabledBorder: widget.enabledBorder,
            focusedBorder: widget.focusedBorder,
            borderRadius: widget.borderRadius,
            validator: widget.validator,
            prefixIcon: widget.prefixIcon,
            suffixIcon: widget.showSuffixIcon
                ? (widget.suffixIcon ??
                      Padding(
                        padding: const EdgeInsets.all(
                          AppConstants.paddingSmall + 2,
                        ),
                        child: SvgPicture.asset(
                          AppIcons.calendarSvg,
                          width: AppConstants.iconSize,
                          height: AppConstants.iconSize,
                          fit: BoxFit.scaleDown,
                          colorFilter: const ColorFilter.mode(
                            AppColors.gray500,
                            BlendMode.srcIn,
                          ),
                        ),
                      ))
                : widget.suffixIcon,
          ),
        ),
      ),
    );
  }
}
