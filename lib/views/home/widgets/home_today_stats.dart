import 'package:flutter/material.dart';
import 'package:desilynks/core/constants/app_constants.dart';
import 'package:desilynks/core/constants/app_strings.dart';
import 'package:desilynks/core/constants/app_colors.dart';
import 'package:desilynks/core/extensions/context_extensions.dart';
import 'package:desilynks/app/routes.dart';

class HomeTodayStats extends StatelessWidget {
  final String userCity;
  final int? jobsCount;
  final int? roomsCount;
  final int? workersCount;
  final int? dealsCount;
  final int? totalPostings;
  final bool? isLoading;

  const HomeTodayStats({
    super.key,
    required this.userCity,
    this.jobsCount,
    this.roomsCount,
    this.workersCount,
    this.dealsCount,
    this.totalPostings,
    this.isLoading,
  });

  String _formatCount(int count) {
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}k';
    }
    return count.toString();
  }

  @override
  Widget build(BuildContext context) {
    final int jobs = jobsCount ?? 12;
    final int rooms = roomsCount ?? 8;
    final int workers = workersCount ?? 15;
    final int deals = dealsCount ?? 15;
    final int total = totalPostings ?? (jobs + rooms + workers + deals);
    final bool loading = isLoading ?? false;

    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingLarge),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        boxShadow: const [
          BoxShadow(
            color: AppColors.blackOpacity4,
            blurRadius: AppConstants.borderRadiusExtraSmall,
            offset: Offset(0, AppConstants.borderRadiusExtraSmall),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  '${AppStrings.todayInCityPrefix}$userCity',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: AppConstants.fontSizeLG,
                    fontWeight: FontWeight.w600,
                    color: AppColors.slate800,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.softGreen,
                  borderRadius: BorderRadius.circular(
                    AppConstants.borderRadius12,
                  ),
                  border: Border.all(
                    color: AppColors.emerald.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppColors.emerald,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      '$total ${AppStrings.labelLive}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.green600,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.paddingLarge),
          Row(
            children: [
              Expanded(
                child: _buildStatColumn(
                  context,
                  loading ? '...' : _formatCount(jobs),
                  AppStrings.tagNewJobs,
                  AppColors.primaryBlue,
                ),
              ),
              Expanded(
                child: _buildStatColumn(
                  context,
                  loading ? '...' : _formatCount(rooms),
                  AppStrings.tagNewRooms,
                  AppColors.orangeAccent,
                ),
              ),
              Expanded(
                child: _buildStatColumn(
                  context,
                  loading ? '...' : _formatCount(workers),
                  AppStrings.tagWorkers,
                  AppColors.successGreen,
                ),
              ),
              Expanded(
                child: _buildStatColumn(
                  context,
                  loading ? '...' : _formatCount(deals),
                  AppStrings.tagNewDeals,
                  AppColors.primaryRed,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(
    BuildContext context,
    String val,
    String title,
    Color color,
  ) {
    final bool isSmall = context.isSmall;

    return GestureDetector(
      onTap: () {
        final t = title.toLowerCase();
        if (t.contains('worker')) {
          Navigator.pushNamed(context, AppRoutes.hireWorkers);
        } else if (t.contains('job')) {
          Navigator.pushNamed(context, AppRoutes.jobs);
        } else if (t.contains('room')) {
          Navigator.pushNamed(context, AppRoutes.roomDetails);
        } else if (t.contains('deal')) {
          Navigator.pushNamed(context, AppRoutes.dealsDiscounts);
        }
      },
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          Text(
            val,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: isSmall
                  ? AppConstants.fontSizeTitle
                  : AppConstants.fontSizeHeading,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: AppConstants.padding2),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isSmall ? 10.0 : 11.0,
              color: AppColors.slate500,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
