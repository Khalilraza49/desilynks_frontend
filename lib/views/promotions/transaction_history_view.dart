import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/svg.dart';
import 'package:desilynks/core/constants/app_colors.dart';
import 'package:desilynks/core/constants/app_icons.dart';
import 'package:desilynks/core/constants/app_strings.dart';
import 'package:desilynks/core/extensions/context_extensions.dart';
import 'package:desilynks/viewmodels/promotions/transaction_history_viewmodel.dart';

class TransactionHistoryView extends StatelessWidget {
  const TransactionHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<TransactionHistoryViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: SvgPicture.asset(
            AppIcons.arrowBackBasicSvg,
            colorFilter: const ColorFilter.mode(
              AppColors.slate900,
              BlendMode.srcIn,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          'Transaction History',
          style: TextStyle(
            color: AppColors.slate900,
            fontSize: context.sp(18),
            fontWeight: FontWeight.bold,
            fontFamily: AppStrings.fontInter,
          ),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            children: [
              // 1. Top Tab Selection Bar
              Container(
                color: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: context.hMargin),
                child: Row(
                  children: List.generate(
                    viewModel.tabTitles.length,
                    (index) => _buildTabItem(
                      context,
                      viewModel,
                      index,
                      viewModel.tabTitles[index],
                    ),
                  ),
                ),
              ),
              const Divider(height: 1, color: Color(0xFFE2E8F0)),

              // 2. Scrollable Transaction Cards List
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.all(context.scale(16)),
                  itemCount: viewModel.currentList.length,
                  itemBuilder: (ctx, index) {
                    final item = viewModel.currentList[index];
                    return _buildTransactionCard(context, item);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabItem(
    BuildContext context,
    TransactionHistoryViewModel viewModel,
    int index,
    String label,
  ) {
    final isSelected = viewModel.selectedTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => viewModel.selectTab(index),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: context.scaleH(14)),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected
                    ? const Color(0xFF2563EB)
                    : Colors.transparent,
                width: 2.5,
              ),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: context.sp(14),
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected
                  ? const Color(0xFF2563EB)
                  : const Color(0xFF94A3B8),
              fontFamily: AppStrings.fontInter,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionCard(BuildContext context, TransactionRecord item) {
    return Padding(
      padding: EdgeInsets.only(bottom: context.scaleH(12)),
      child: Container(
        padding: EdgeInsets.all(context.scale(14)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(context.scale(16)),
          border: Border.all(color: const Color(0xFFF1F5F9), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Left Status Icon Box
            Container(
              width: context.scale(44),
              height: context.scale(44),
              decoration: BoxDecoration(
                color: item.iconBgColor,
                borderRadius: BorderRadius.circular(context.scale(12)),
              ),
              child: Center(
                child: SvgPicture.asset(
                  item.icon,
                  colorFilter: ColorFilter.mode(
                    item.iconColor,
                    BlendMode.srcIn,
                  ),
                  height: context.scale(22),
                  width: context.scale(22),
                ),
              ),
            ),
            SizedBox(width: context.scale(14)),

            // Center Title & Date
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: TextStyle(
                      fontSize: context.sp(14.5),
                      fontWeight: FontWeight.bold,
                      color: AppColors.slate900,
                      fontFamily: AppStrings.fontInter,
                    ),
                  ),
                  SizedBox(height: context.scaleH(3)),
                  Text(
                    item.date,
                    style: TextStyle(
                      fontSize: context.sp(12),
                      color: const Color(0xFF94A3B8),
                      fontFamily: AppStrings.fontInter,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(width: context.scale(10)),

            // Right Amount & Status Tag
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  item.amount,
                  style: TextStyle(
                    fontSize: context.sp(14.5),
                    fontWeight: FontWeight.bold,
                    color: AppColors.slate900,
                    fontFamily: AppStrings.fontInter,
                  ),
                ),
                SizedBox(height: context.scaleH(2)),
                Text(
                  item.status,
                  style: TextStyle(
                    fontSize: context.sp(11.5),
                    fontWeight: FontWeight.bold,
                    color: item.statusColor,
                    fontFamily: AppStrings.fontInter,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
