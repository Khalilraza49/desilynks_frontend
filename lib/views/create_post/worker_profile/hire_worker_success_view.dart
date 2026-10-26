import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:desilynks/core/extensions/context_extensions.dart';
import 'package:desilynks/core/constants/app_colors.dart';
import 'package:desilynks/core/constants/app_icons.dart';
import 'package:desilynks/core/constants/app_strings.dart';
import 'package:desilynks/app/routes.dart';
import 'package:desilynks/viewmodels/create_post/worker_viewmodel.dart';

class HireWorkerSuccessView extends StatelessWidget {
  final Map<String, dynamic>? requestData;

  const HireWorkerSuccessView({super.key, this.requestData});

  @override
  Widget build(BuildContext context) {
    final workerVM = context.watch<WorkerViewModel>();
    final effectiveData = requestData ?? workerVM.lastHireRequestData;

    final workerName = effectiveData?['workerName'] as String? ?? 'Ali Khan';
    final profession = effectiveData?['profession'] as String? ?? 'Electrician';
    final hourlyRate = effectiveData?['hourlyRate']?.toString() ?? '18';
    final avatar = effectiveData?['avatar'] as String? ?? '';
    final service = effectiveData?['service'] as String? ?? 'Electrical Repair';
    final location = effectiveData?['location'] as String? ?? 'Madrid, Spain';
    final budget = effectiveData?['budget'] as String? ?? '100';

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 540),
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: context.hMargin,
                vertical: context.scaleH(12).clamp(8.0, 16.0),
              ),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: context.scaleH(10).clamp(6.0, 14.0)),

                  // 1. Paper Plane Top Icon Container
                  Container(
                    width: context.scale(90).clamp(76.0, 100.0),
                    height: context.scale(90).clamp(76.0, 100.0),
                    decoration: BoxDecoration(
                      color: AppColors.indigoLight, // Soft Blue Tint
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.indigo.withValues(alpha: 0.15),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: SvgPicture.asset(
                      AppIcons.send2,
                      colorFilter: const ColorFilter.mode(
                        AppColors.primaryBlue,
                        BlendMode.srcIn,
                      ),
                      width: context.scale(38).clamp(30.0, 44.0),
                      height: context.scale(38).clamp(30.0, 44.0),
                    ),
                  ),

                  SizedBox(height: context.scaleH(24).clamp(16.0, 28.0)),

                  // 2. Heading Title
                  Text(
                    'Request Sent!',
                    style: TextStyle(
                      fontSize: context.sp(24).clamp(20.0, 28.0),
                      fontWeight: FontWeight.bold,
                      color: AppColors.slate900,
                      fontFamily: AppStrings.fontInter,
                    ),
                  ),

                  SizedBox(height: context.scaleH(8).clamp(4.0, 12.0)),

                  // 3. Subtitle with Bold Worker Name
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: context.scale(16).clamp(8.0, 20.0),
                    ),
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: context.sp(14).clamp(12.5, 16.0),
                          color: AppColors.slate500,
                          height: 1.4,
                          fontFamily: AppStrings.fontInter,
                        ),
                        children: [
                          const TextSpan(
                            text: 'Your hire request has been sent to\n',
                          ),
                          TextSpan(
                            text: workerName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.slate900,
                            ),
                          ),
                          const TextSpan(
                            text: ". You'll be notified once he responds.",
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: context.scaleH(32).clamp(20.0, 36.0)),

                  // 4. Request Details Summary Card
                  Container(
                    padding: EdgeInsets.all(
                      context.scale(20).clamp(16.0, 24.0),
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(
                        context.scale(20).clamp(16.0, 24.0),
                      ),
                      border: Border.all(color: AppColors.slate100, width: 1.5),
                      boxShadow: const [
                        BoxShadow(
                          color: AppColors.blackOpacity4,
                          blurRadius: 12,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Worker Header Row with Pending Badge
                        Row(
                          children: [
                            CircleAvatar(
                              radius: context.scale(24).clamp(20.0, 28.0),
                              backgroundColor: AppColors.lightBlue,
                              backgroundImage: avatar.isNotEmpty
                                  ? NetworkImage(avatar)
                                  : null,
                              child: avatar.isEmpty
                                  ? SvgPicture.asset(
                                      AppIcons.personSvg,
                                      colorFilter: const ColorFilter.mode(
                                        AppColors.primaryBlue,
                                        BlendMode.srcIn,
                                      ),
                                      width: context.scale(24).clamp(20.0, 28.0),
                                      height: context.scale(24).clamp(20.0, 28.0),
                                    )
                                  : null,
                            ),
                            SizedBox(width: context.scale(12).clamp(8.0, 16.0)),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    workerName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: context.sp(16).clamp(14.0, 18.0),
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.slate900,
                                      fontFamily: AppStrings.fontInter,
                                    ),
                                  ),
                                  SizedBox(height: context.scaleH(2).clamp(1.0, 4.0)),
                                  Text(
                                    '$profession • €$hourlyRate/hr',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: context.sp(12.5).clamp(11.0, 14.0),
                                      color: AppColors.slate500,
                                      fontFamily: AppStrings.fontInter,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: context.scale(8).clamp(4.0, 10.0)),
                            // Pending Status Badge
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: context.scale(12).clamp(8.0, 14.0),
                                vertical: context.scaleH(5).clamp(3.0, 6.0),
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.amber100, // Light Gold Pill
                                borderRadius: BorderRadius.circular(
                                  context.scale(16).clamp(12.0, 18.0),
                                ),
                              ),
                              child: Text(
                                'Pending',
                                style: TextStyle(
                                  fontSize: context.sp(12).clamp(10.5, 13.0),
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.accentYellow, // Gold Text
                                  fontFamily: AppStrings.fontInter,
                                ),
                              ),
                            ),
                          ],
                        ),

                        Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: context.scaleH(16).clamp(12.0, 18.0),
                          ),
                          child: const Divider(color: AppColors.slate100, height: 1),
                        ),

                        // Detail Key-Value Rows
                        _buildDetailRow(
                          context,
                          label: 'Service',
                          value: service,
                          valueColor: AppColors.slate900,
                          valueBold: true,
                        ),
                        SizedBox(height: context.scaleH(12).clamp(8.0, 14.0)),
                        _buildDetailRow(
                          context,
                          label: 'Location',
                          value: location,
                          valueColor: AppColors.slate900,
                          valueBold: true,
                        ),
                        SizedBox(height: context.scaleH(12).clamp(8.0, 14.0)),
                        _buildDetailRow(
                          context,
                          label: 'Budget',
                          value: '€$budget',
                          valueColor: AppColors.primaryBlue, // Vibrant Blue
                          valueBold: true,
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: context.scaleH(40).clamp(24.0, 44.0)),

                  // 5. Primary Action Button - View My Requests
                  SizedBox(
                    width: double.infinity,
                    height: context.scaleH(52).clamp(46.0, 56.0),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(
                          context,
                          AppRoutes.workerRequests,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        foregroundColor: AppColors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            context.scale(16).clamp(12.0, 18.0),
                          ),
                        ),
                      ),
                      child: Text(
                        'View My Requests',
                        style: TextStyle(
                          fontSize: context.sp(16).clamp(14.0, 18.0),
                          fontWeight: FontWeight.bold,
                          fontFamily: AppStrings.fontInter,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: context.scaleH(16).clamp(10.0, 18.0)),

                  // 6. Secondary Action Button - Back to Home
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        AppRoutes.home,
                        (route) => false,
                      );
                    },
                    child: Text(
                      'Back to Home',
                      style: TextStyle(
                        fontSize: context.sp(14).clamp(12.5, 15.5),
                        fontWeight: FontWeight.w600,
                        color: AppColors.slate500,
                        fontFamily: AppStrings.fontInter,
                      ),
                    ),
                  ),

                  SizedBox(height: context.scaleH(20).clamp(12.0, 24.0)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context, {
    required String label,
    required String value,
    required Color valueColor,
    bool valueBold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: context.sp(13).clamp(11.5, 14.5),
            color: AppColors.slate400,
            fontFamily: AppStrings.fontInter,
          ),
        ),
        SizedBox(width: context.scale(12).clamp(8.0, 16.0)),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: context.sp(14).clamp(12.5, 15.5),
              fontWeight: valueBold ? FontWeight.bold : FontWeight.w500,
              color: valueColor,
              fontFamily: AppStrings.fontInter,
            ),
          ),
        ),
      ],
    );
  }
}
