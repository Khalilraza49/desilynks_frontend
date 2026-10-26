import 'package:flutter/material.dart';

/// A compact, desktop/Chromium-styled 3-column time picker popup
/// matching the exact layout shown in the design specification:
/// - Header row with 3 boxes (Hour, Minute, Period) with active focus border
/// - 3 scrollable vertical columns for selecting Hours, Minutes, and AM/PM
class CustomTimePickerDialog extends StatefulWidget {
  final TimeOfDay initialTime;

  const CustomTimePickerDialog({super.key, required this.initialTime});

  @override
  State<CustomTimePickerDialog> createState() => _CustomTimePickerDialogState();
}

class _CustomTimePickerDialogState extends State<CustomTimePickerDialog> {
  late int _selectedHour12; // 1 to 12
  late int _selectedMinute; // 0 to 59
  late DayPeriod _selectedPeriod; // DayPeriod.am or DayPeriod.pm

  // 0: Hour, 1: Minute, 2: Period
  int _focusedColumn = 0;

  final ScrollController _hourScrollController = ScrollController();
  final ScrollController _minuteScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    final hour = widget.initialTime.hourOfPeriod == 0
        ? 12
        : widget.initialTime.hourOfPeriod;
    _selectedHour12 = hour;
    _selectedMinute = widget.initialTime.minute;
    _selectedPeriod = widget.initialTime.period;
  }

  @override
  void dispose() {
    _hourScrollController.dispose();
    _minuteScrollController.dispose();
    super.dispose();
  }

  TimeOfDay _getCurrentTime() {
    int hour24;
    if (_selectedPeriod == DayPeriod.am) {
      hour24 = _selectedHour12 == 12 ? 0 : _selectedHour12;
    } else {
      hour24 = _selectedHour12 == 12 ? 12 : _selectedHour12 + 12;
    }
    return TimeOfDay(hour: hour24, minute: _selectedMinute);
  }

  // Generates 11 other hours in cyclic order starting from next
  List<int> _getAvailableHours() {
    final List<int> list = [];
    for (int i = 1; i <= 11; i++) {
      int next = (_selectedHour12 + i) % 12;
      if (next == 0) next = 12;
      list.add(next);
    }
    return list;
  }

  // Generates other minutes (all 59 other minutes)
  List<int> _getAvailableMinutes() {
    final List<int> list = [];
    for (int i = 1; i <= 59; i++) {
      list.add((_selectedMinute + i) % 60);
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final hourStr = _selectedHour12.toString().padLeft(2, '0');
    final minuteStr = _selectedMinute.toString().padLeft(2, '0');
    final periodStr = _selectedPeriod == DayPeriod.am ? 'AM' : 'PM';

    final otherHours = _getAvailableHours();
    final otherMinutes = _getAvailableMinutes();
    final otherPeriod = _selectedPeriod == DayPeriod.am ? 'PM' : 'AM';

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Center(
        child: Container(
          width: 215,
          height: 310,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(3),
            border: Border.all(color: const Color(0xFFC4C4C4), width: 1.2),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              // ── Top Header Row (Selected Values) ──────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(6, 6, 6, 4),
                child: Row(
                  children: [
                    // Hour Box
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _focusedColumn = 0),
                        child: _buildHeaderBox(
                          hourStr,
                          isFocused: _focusedColumn == 0,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    // Minute Box
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _focusedColumn = 1),
                        child: _buildHeaderBox(
                          minuteStr,
                          isFocused: _focusedColumn == 1,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    // Period Box
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _focusedColumn = 2),
                        child: _buildHeaderBox(
                          periodStr,
                          isFocused: _focusedColumn == 2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── 3 Column Lists ─────────────────────────────────────────
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Column 0: Hours
                    Expanded(
                      child: Scrollbar(
                        controller: _hourScrollController,
                        thumbVisibility: false,
                        child: ListView.builder(
                          controller: _hourScrollController,
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          itemCount: otherHours.length,
                          itemExtent: 32,
                          itemBuilder: (context, index) {
                            final h = otherHours[index];
                            final hText = h.toString().padLeft(2, '0');
                            return InkWell(
                              onTap: () {
                                setState(() {
                                  _selectedHour12 = h;
                                  _focusedColumn = 0;
                                });
                              },
                              child: Center(
                                child: Text(
                                  hText,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.normal,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                    // Column 1: Minutes
                    Expanded(
                      child: Scrollbar(
                        controller: _minuteScrollController,
                        thumbVisibility: false,
                        child: ListView.builder(
                          controller: _minuteScrollController,
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          itemCount: otherMinutes.length,
                          itemExtent: 32,
                          itemBuilder: (context, index) {
                            final m = otherMinutes[index];
                            final mText = m.toString().padLeft(2, '0');
                            return InkWell(
                              onTap: () {
                                setState(() {
                                  _selectedMinute = m;
                                  _focusedColumn = 1;
                                });
                              },
                              child: Center(
                                child: Text(
                                  mText,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.normal,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                    // Column 2: Period (AM/PM)
                    Expanded(
                      child: Column(
                        children: [
                          InkWell(
                            onTap: () {
                              setState(() {
                                _selectedPeriod =
                                    _selectedPeriod == DayPeriod.am
                                    ? DayPeriod.pm
                                    : DayPeriod.am;
                                _focusedColumn = 2;
                              });
                            },
                            child: SizedBox(
                              height: 32,
                              child: Center(
                                child: Text(
                                  otherPeriod,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.normal,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ── Bottom Action Footer ──────────────────────────────────
              Container(
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Color(0xFFE2E8F0), width: 1),
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        minimumSize: const Size(48, 30),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        minimumSize: const Size(48, 30),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: () =>
                          Navigator.pop(context, _getCurrentTime()),
                      child: const Text(
                        'OK',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderBox(String text, {required bool isFocused}) {
    return Container(
      height: 38,
      decoration: BoxDecoration(
        color: const Color(0xFFCCCCCC),
        borderRadius: BorderRadius.circular(2),
        border: isFocused
            ? Border.all(color: Colors.black, width: 2)
            : Border.all(color: Colors.transparent, width: 2),
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }
}
