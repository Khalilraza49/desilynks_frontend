import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:desilynks/core/constants/app_colors.dart';
import 'package:desilynks/core/constants/app_constants.dart';
import 'package:desilynks/core/extensions/context_extensions.dart';
import 'package:desilynks/models/moderation_models.dart';
import 'package:desilynks/viewmodels/moderation/moderation_viewmodel.dart';
import 'package:desilynks/widgets/custom_button.dart';

class ReportBottomSheet extends StatefulWidget {
  final ReportTargetType targetType;
  final String targetId;
  final String? targetOwnerId;
  final String? targetTitle;

  const ReportBottomSheet({
    super.key,
    required this.targetType,
    required this.targetId,
    this.targetOwnerId,
    this.targetTitle,
  });

  /// Static helper to display the report bottom sheet anywhere
  static Future<void> show(
    BuildContext context, {
    required ReportTargetType targetType,
    required String targetId,
    String? targetOwnerId,
    String? targetTitle,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppConstants.borderRadius20),
        ),
      ),
      builder: (ctx) => ReportBottomSheet(
        targetType: targetType,
        targetId: targetId,
        targetOwnerId: targetOwnerId,
        targetTitle: targetTitle,
      ),
    );
  }

  @override
  State<ReportBottomSheet> createState() => _ReportBottomSheetState();
}

class _ReportBottomSheetState extends State<ReportBottomSheet> {
  ReportReason _selectedReason = ReportReason.spam;
  final TextEditingController _detailsController = TextEditingController();
  String? _validationError;

  @override
  void dispose() {
    _detailsController.dispose();
    super.dispose();
  }

  Future<void> _submitReport() async {
    final detailsText = _detailsController.text.trim();

    // Required details when reason is OTHER
    if (_selectedReason == ReportReason.other && detailsText.isEmpty) {
      setState(() {
        _validationError = 'Please provide details explaining the issue';
      });
      return;
    }

    if (detailsText.length > 1000) {
      setState(() {
        _validationError = 'Details cannot exceed 1000 characters';
      });
      return;
    }

    setState(() {
      _validationError = null;
    });

    final moderationVm = Provider.of<ModerationViewModel>(
      context,
      listen: false,
    );

    final result = await moderationVm.submitReport(
      targetType: widget.targetType,
      targetId: widget.targetId,
      reason: _selectedReason,
      details: detailsText.isNotEmpty ? detailsText : null,
    );

    if (!mounted) return;

    if (result != null) {
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.contains('already reported')
                ? "You've already reported this"
                : "Thanks, we'll review this",
          ),
          backgroundColor: Colors.green.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );

      // Offer to block if reporting a user, message, or comment
      final personToBlockId = widget.targetType == ReportTargetType.user
          ? widget.targetId
          : widget.targetOwnerId;

      if (personToBlockId != null &&
          personToBlockId.isNotEmpty &&
          !moderationVm.isUserBlocked(personToBlockId)) {
        _showBlockPromptDialog(context, personToBlockId);
      }
    } else {
      setState(() {
        _validationError = moderationVm.errorMessage ??
            'Failed to submit report. Please try again.';
      });
    }
  }

  void _showBlockPromptDialog(BuildContext context, String userIdToBlock) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius16),
        ),
        title: const Row(
          children: [
            Icon(Icons.block, color: AppColors.primaryRed, size: 22),
            SizedBox(width: 8),
            Text(
              'Also block this person?',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: const Text(
          "They won't be able to message you, and their posts and comments will be hidden from your feed.",
          style: TextStyle(fontSize: 13.5, color: AppColors.slate600, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('No, Thanks', style: TextStyle(color: AppColors.slate600)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryRed,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
              ),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              final modVm = Provider.of<ModerationViewModel>(context, listen: false);
              final blocked = await modVm.blockUser(userIdToBlock);
              if (context.mounted && blocked) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('User blocked successfully'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: const Text('Block', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final isSubmitting = context.watch<ModerationViewModel>().isSubmittingReport;

    return SafeArea(
      child: AnimatedPadding(
        padding: EdgeInsets.only(bottom: bottomInset),
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: context.scale(20),
            vertical: context.scale(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Drag Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.slate200,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Title Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.redLight100,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.flag_rounded,
                      color: AppColors.primaryRed,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.targetTitle ?? 'Report ${widget.targetType.label}',
                          style: TextStyle(
                            fontSize: context.sp(16),
                            fontWeight: FontWeight.bold,
                            color: AppColors.slate900,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Help us keep the community safe.',
                          style: TextStyle(
                            fontSize: context.sp(11.5),
                            color: AppColors.slate500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.slate500, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              Text(
                'Why are you reporting this?',
                style: TextStyle(
                  fontSize: context.sp(13),
                  fontWeight: FontWeight.w600,
                  color: AppColors.slate800,
                ),
              ),
              const SizedBox(height: 8),

              // Radio List of Reasons
              Container(
                decoration: BoxDecoration(
                  color: AppColors.slate50,
                  borderRadius: BorderRadius.circular(AppConstants.borderRadius12),
                  border: Border.all(color: AppColors.slate200),
                ),
                child: Column(
                  children: ReportReason.values.map((reason) {
                    final isSelected = _selectedReason == reason;
                    return InkWell(
                      onTap: () {
                        setState(() {
                          _selectedReason = reason;
                          _validationError = null;
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        child: Row(
                          children: [
                            Icon(
                              isSelected
                                  ? Icons.radio_button_checked
                                  : Icons.radio_button_unchecked,
                              color: isSelected ? AppColors.primaryBlue : AppColors.slate400,
                              size: 19,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                reason.label,
                                style: TextStyle(
                                  fontSize: context.sp(13),
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                  color: isSelected ? AppColors.slate900 : AppColors.slate700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 14),

              // Additional Details Text Box with Character Counter
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _selectedReason == ReportReason.other
                        ? 'Details (required)'
                        : 'Additional details (optional)',
                    style: TextStyle(
                      fontSize: context.sp(12.5),
                      fontWeight: FontWeight.w600,
                      color: AppColors.slate800,
                    ),
                  ),
                  ValueListenableBuilder<TextEditingValue>(
                    valueListenable: _detailsController,
                    builder: (context, value, _) {
                      final count = value.text.length;
                      return Text(
                        '$count / 1000',
                        style: TextStyle(
                          fontSize: context.sp(11),
                          color: count > 1000 ? AppColors.primaryRed : AppColors.slate400,
                          fontWeight: FontWeight.w500,
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _detailsController,
                maxLines: 3,
                maxLength: 1000,
                buildCounter: (ctx, {required currentLength, required isFocused, maxLength}) => null,
                style: TextStyle(fontSize: context.sp(13), color: AppColors.slate900),
                decoration: InputDecoration(
                  hintText: _selectedReason == ReportReason.other
                      ? 'Please describe why you are reporting this...'
                      : 'Provide any additional context (optional)...',
                  hintStyle: TextStyle(color: AppColors.slate400, fontSize: context.sp(12.5)),
                  filled: true,
                  fillColor: AppColors.slate50,
                  contentPadding: const EdgeInsets.all(12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
                    borderSide: const BorderSide(color: AppColors.slate200),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
                    borderSide: const BorderSide(color: AppColors.slate200),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
                    borderSide: const BorderSide(color: AppColors.primaryBlue, width: 1.4),
                  ),
                ),
              ),

              if (_validationError != null) ...[
                const SizedBox(height: 6),
                Text(
                  _validationError!,
                  style: const TextStyle(
                    color: AppColors.primaryRed,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
              const SizedBox(height: 16),

              // Submit Button
              CustomButton(
                text: 'Submit Report',
                onPressed: isSubmitting ? null : _submitReport,
                isLoading: isSubmitting,
                backgroundColor: AppColors.primaryRed,
                borderRadius: AppConstants.borderRadius10.toDouble(),
                fontWeight: FontWeight.bold,
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
