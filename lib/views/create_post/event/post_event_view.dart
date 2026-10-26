import 'dart:io';
import 'package:desilynks/core/constants/app_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:desilynks/core/constants/app_colors.dart';
import 'package:desilynks/core/constants/app_constants.dart';
import 'package:desilynks/core/constants/app_strings.dart';
import 'package:desilynks/viewmodels/events/events_viewmodel.dart';
import 'package:desilynks/widgets/custom_text_field.dart';
import 'package:desilynks/widgets/custom_date_picker_field.dart';
import 'package:desilynks/widgets/custom_time_picker_dialog.dart';

class PostEventView extends StatelessWidget {
  const PostEventView({super.key});

  Future<void> _selectStartTime(BuildContext context, EventsViewModel vm) async {
    final TimeOfDay? picked = await showDialog<TimeOfDay>(
      context: context,
      barrierColor: Colors.black26,
      builder: (context) => CustomTimePickerDialog(
        initialTime: vm.startTime ?? const TimeOfDay(hour: 9, minute: 0),
      ),
    );
    if (picked != null) {
      vm.setStartTime(picked);
    }
  }

  Future<void> _selectEndTime(BuildContext context, EventsViewModel vm) async {
    final TimeOfDay? picked = await showDialog<TimeOfDay>(
      context: context,
      barrierColor: Colors.black26,
      builder: (context) => CustomTimePickerDialog(
        initialTime: vm.endTime ?? const TimeOfDay(hour: 17, minute: 0),
      ),
    );
    if (picked != null) {
      vm.setEndTime(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<EventsViewModel>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      vm.initEventForm();
    });

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            // 1. Top Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  // Back button
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: AppColors.slate100,
                        shape: BoxShape.circle,
                      ),
                      child: SvgPicture.asset(
                        AppIcons.arrowBackSvg,
                        width: 18,
                        height: 18,
                        colorFilter: const ColorFilter.mode(
                          AppColors.slate500,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  const Text(
                    'Create  Event',
                    style: TextStyle(
                      fontSize: AppConstants.fontSizeXXL,
                      fontWeight: FontWeight.bold,
                      color: AppColors.slate800,
                    ),
                  ),
                  const Spacer(),
                  const SizedBox(width: 34),
                ],
              ),
            ),

            const Divider(color: AppColors.slate200, height: 1, thickness: 1),

            // Form Body
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Animated Progress Bar
                    _buildAnimatedProgressBar(vm),
                    const SizedBox(height: 24),

                    // Event Banner
                    _buildFieldLabel('Event Banner', isRequired: false),
                    const SizedBox(height: 10),
                    _buildEventBannerSlot(context, vm),

                    const SizedBox(height: 20),

                    // Event Name *
                    _buildFieldLabel('Event Name', isRequired: true),
                    const SizedBox(height: 8),
                    CustomTextField(
                      controller: vm.eventNameController,
                      hintText:
                          'e.g. Eid Celebration 2024, Cricket Tournament',
                    ),

                    const SizedBox(height: 20),

                    // Organizer / Group
                    _buildFieldLabel('Organizer / Group', isRequired: false),
                    const SizedBox(height: 8),
                    _buildOrganizerDropdown(vm),

                    const SizedBox(height: 20),

                    // Date & Time *
                    _buildFieldLabel('Date & Time', isRequired: true),
                    const SizedBox(height: 10),
                    _buildDateTimeCard(context, vm),

                    const SizedBox(height: 20),

                    // Venue / Location *
                    _buildFieldLabel(
                      'Venue / Location',
                      isRequired: !vm.isOnlineEvent,
                    ),
                    const SizedBox(height: 8),
                    CustomTextField(
                      controller: vm.locationController,
                      hintText: 'e.g. Parque del Retiro, Madrid',
                      prefixIcon: Padding(
                        padding: const EdgeInsets.all(12),
                        child: SvgPicture.asset(
                          AppIcons.locationSvg,
                          height: 24,
                          width: 24,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Description *
                    _buildFieldLabel('Description', isRequired: true),
                    const SizedBox(height: 8),
                    CustomTextField(
                      controller: vm.descriptionController,
                      hintText:
                          'Tell people what this event is about, what to bring, dress code...',
                      maxLines: 4,
                    ),

                    const SizedBox(height: 20),

                    // Ticket Price & Max Attendees Row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Ticket Price
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildFieldLabel(
                                'Ticket Price',
                                isRequired: false,
                              ),
                              const SizedBox(height: 8),
                              CustomTextField(
                                controller: vm.ticketPriceController,
                                hintText: '€ 0 = Free',
                                keyboardType: TextInputType.number,
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                '0 for free event',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.slate400,
                                  fontFamily: AppStrings.fontInter,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Max Attendees
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildFieldLabel(
                                'Max Attendees',
                                isRequired: false,
                              ),
                              const SizedBox(height: 8),
                              _buildMaxAttendeesStepper(vm),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Event Type Chips
                    _buildFieldLabel('Event Type', isRequired: false),
                    const SizedBox(height: 10),
                    _buildEventTypeChips(vm),

                    const SizedBox(height: 24),

                    // Event Visibility Selector
                    _buildFieldLabel('Event Visibility', isRequired: false),
                    const SizedBox(height: 10),
                    _buildEventVisibilitySelector(vm),

                    const SizedBox(height: 32),

                    // Create Event Button
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            AppColors.vibrantBlue,
                            AppColors.secondaryPurple,
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: vm.isLoading
                          ? const Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 12),
                                child: CircularProgressIndicator(
                                  color: AppColors.white,
                                ),
                              ),
                            )
                          : ElevatedButton.icon(
                              onPressed: () => vm.publishEvent(context),
                              icon: SvgPicture.asset(
                                AppIcons.calendarSvg,
                                colorFilter: const ColorFilter.mode(
                                  AppColors.white,
                                  BlendMode.srcIn,
                                ),
                                width: 18,
                                height: 18,
                              ),
                              label: const Text(
                                'Create Event',
                                style: TextStyle(
                                  color: AppColors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.transparent,
                                shadowColor: AppColors.transparent,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                elevation: 0,
                              ),
                            ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Field Label Helper
  Widget _buildFieldLabel(String text, {required bool isRequired}) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: text,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.slate800,
              fontFamily: AppStrings.fontInter,
            ),
          ),
          if (isRequired)
            const TextSpan(
              text: ' *',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryRed,
              ),
            ),
        ],
      ),
    );
  }

  // Event Banner Slot
  Widget _buildEventBannerSlot(BuildContext context, EventsViewModel vm) {
    if (vm.bannerImage != null) {
      return Container(
        height: 140,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.emerald, width: 1.5),
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14.5),
              child: Image.file(
                File(vm.bannerImage!.path),
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              right: 8,
              top: 8,
              child: GestureDetector(
                onTap: vm.removeBanner,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: SvgPicture.asset(
                    AppIcons.crossSmallSvg,
                    height: 16,
                    width: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return GestureDetector(
      onTap: () => vm.pickBanner(context),
      child: Container(
        width: double.infinity,
        height: 140,
        decoration: BoxDecoration(
          color: const Color(0xFFECFDF5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF34D399), width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0F000000),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: SvgPicture.asset(
                AppIcons.gallerySvg,
                colorFilter: const ColorFilter.mode(
                  Color(0xFF34D399),
                  BlendMode.srcIn,
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Upload Event Banner',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF059669),
                fontFamily: AppStrings.fontInter,
              ),
            ),
            const SizedBox(height: 2),
            const Text(
              'Recommended: 1200×628',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF9CA3AF),
                fontFamily: AppStrings.fontInter,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Organizer / Group Dropdown Selector
  Widget _buildOrganizerDropdown(EventsViewModel vm) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.0),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          dropdownColor: Colors.white,
          value: vm.selectedOrganizer.isEmpty ? null : vm.selectedOrganizer,
          hint: const Text(
            'Select Organizer / Group',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.slate400,
              fontFamily: AppStrings.fontInter,
            ),
          ),
          isExpanded: true,
          icon: SvgPicture.asset(AppIcons.arrowDropDownSvg),
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: AppColors.slate800,
            fontFamily: AppStrings.fontInter,
          ),
          onChanged: (String? newValue) {
            if (newValue != null) {
              vm.setSelectedOrganizer(newValue);
            }
          },
          items: EventsViewModel.organizers
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(value: value, child: Text(value));
          }).toList(),
        ),
      ),
    );
  }

  // Date & Time Card Widget
  Widget _buildDateTimeCard(BuildContext context, EventsViewModel vm) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // START Section
          const Text(
            'START',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Color(0xFF6B7280),
              letterSpacing: 0.5,
              fontFamily: AppStrings.fontInter,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              // Start Date
              Expanded(
                child: CustomDatePickerField(
                  controller: vm.startDateController,
                  hintText: 'mm/dd/yyyy',
                  fontSize: 12.5,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 12,
                  ),
                  firstDate: DateTime.now(),
                  fillColor: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: Color(0xFFE2E8F0),
                      width: 1.0,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: Color(0xFFE2E8F0),
                      width: 1.0,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: AppColors.vibrantBlue,
                      width: 1.5,
                    ),
                  ),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(left: 8, right: 4),
                    child: SvgPicture.asset(
                      AppIcons.calendarSvg,
                      height: 18,
                      width: 18,
                    ),
                  ),
                  suffixIcon: const SizedBox.shrink(),
                  onDateSelected: (date) {
                    vm.setStartDate(date);
                  },
                ),
              ),
              const SizedBox(width: 8),
              // Start Time
              Expanded(
                child: GestureDetector(
                  onTap: () => _selectStartTime(context, vm),
                  child: Container(
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: const Color(0xFFE2E8F0),
                        width: 1.0,
                      ),
                    ),
                    child: Row(
                      children: [
                        SvgPicture.asset(
                          AppIcons.TimerSvg,
                          height: 18,
                          width: 18,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            vm.startTime != null
                                ? vm.startTime!.format(context)
                                : '--:-- --',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: vm.startTime != null
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              color: vm.startTime != null
                                  ? AppColors.slate800
                                  : AppColors.slate400,
                              fontFamily: AppStrings.fontInter,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // END Section
          const Text(
            'END',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Color(0xFF6B7280),
              letterSpacing: 0.5,
              fontFamily: AppStrings.fontInter,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              // End Date
              Expanded(
                child: CustomDatePickerField(
                  controller: vm.endDateController,
                  hintText: 'mm/dd/yyyy',
                  fontSize: 12.5,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 12,
                  ),
                  firstDate: vm.startDate ?? DateTime.now(),
                  fillColor: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: Color(0xFFE2E8F0),
                      width: 1.0,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: Color(0xFFE2E8F0),
                      width: 1.0,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: AppColors.vibrantBlue,
                      width: 1.5,
                    ),
                  ),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(left: 8, right: 4),
                    child: SvgPicture.asset(
                      AppIcons.calendarSvg,
                      height: 18,
                      width: 18,
                    ),
                  ),
                  suffixIcon: const SizedBox.shrink(),
                  onDateSelected: (date) {
                    vm.setEndDate(date);
                  },
                ),
              ),
              const SizedBox(width: 8),
              // End Time
              Expanded(
                child: GestureDetector(
                  onTap: () => _selectEndTime(context, vm),
                  child: Container(
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: const Color(0xFFE2E8F0),
                        width: 1.0,
                      ),
                    ),
                    child: Row(
                      children: [
                        SvgPicture.asset(
                          AppIcons.TimerSvg,
                          height: 18,
                          width: 18,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            vm.endTime != null
                                ? vm.endTime!.format(context)
                                : '--:-- --',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: vm.endTime != null
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              color: vm.endTime != null
                                  ? AppColors.slate800
                                  : AppColors.slate400,
                              fontFamily: AppStrings.fontInter,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Max Attendees Stepper
  Widget _buildMaxAttendeesStepper(EventsViewModel vm) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton(
            onPressed: vm.decrementAttendees,
            child: const Text(
              "-",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.slate600,
                fontFamily: AppStrings.fontInter,
              ),
            ),
          ),
          Text(
            '${vm.maxAttendees}',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.slate800,
              fontFamily: AppStrings.fontInter,
            ),
          ),
          TextButton(
            onPressed: vm.incrementAttendees,
            child: const Text(
              "+",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.slate600,
                fontFamily: AppStrings.fontInter,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Event Type Chips Wrap
  Widget _buildEventTypeChips(EventsViewModel vm) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: EventsViewModel.eventTypes.map((type) {
        final isSelected = vm.selectedEventType == type['name'];
        return GestureDetector(
          onTap: () {
            vm.setSelectedEventType(type['name']!);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF059669) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFF059669)
                    : const Color(0xFFE2E8F0),
                width: 1.2,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(type['emoji']!, style: const TextStyle(fontSize: 14)),
                const SizedBox(width: 6),
                Text(
                  type['name']!,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? Colors.white : AppColors.slate700,
                    fontFamily: AppStrings.fontInter,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // Event Visibility Segmented Selector
  Widget _buildEventVisibilitySelector(EventsViewModel vm) {
    const options = [
      {'name': 'Public', 'icon': AppIcons.globalSvg},
      {'name': 'Group', 'icon': AppIcons.assetCommuintySvg},
      {'name': 'Invite Only', 'icon': AppIcons.arrowForwardSvg},
    ];

    return Row(
      children: options.map((opt) {
        final isSelected = vm.selectedVisibility == opt['name'];
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: GestureDetector(
              onTap: () {
                vm.setSelectedVisibility(opt['name'] as String);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 52,
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF059669) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF059669)
                        : const Color(0xFFE2E8F0),
                    width: 1.2,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      opt['icon'] as String,
                      height: 18,
                      width: 18,
                      colorFilter: ColorFilter.mode(
                        isSelected ? Colors.white : AppColors.slate600,
                        BlendMode.srcIn,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      opt['name'] as String,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.w500,
                        color: isSelected ? Colors.white : AppColors.slate700,
                        fontFamily: AppStrings.fontInter,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // Animated Progress Bar Widget
  Widget _buildAnimatedProgressBar(EventsViewModel vm) {
    final double targetProgress = vm.calculateProgress();

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: targetProgress),
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
      builder: (context, animatedValue, child) {
        final int percentage = (animatedValue * 100).round();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Step 1 of 2 — Event Details',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.slate600,
                    fontFamily: AppStrings.fontInter,
                  ),
                ),
                Text(
                  '$percentage%',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF10B981),
                    fontFamily: AppStrings.fontInter,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: animatedValue,
                minHeight: 6,
                backgroundColor: AppColors.slate100,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Color(0xFF10B981),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
