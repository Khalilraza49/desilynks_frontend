import 'package:flutter/material.dart';
import '../../core/constants/app_icons.dart';

class TransactionRecord {
  final String title;
  final String date;
  final String amount;
  final String status;
  final String icon;
  final Color iconColor;
  final Color iconBgColor;
  final Color statusColor;

  const TransactionRecord({
    required this.title,
    required this.date,
    required this.amount,
    required this.status,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.statusColor,
  });
}

class TransactionHistoryViewModel extends ChangeNotifier {
  int _selectedTabIndex = 0;
  int get selectedTabIndex => _selectedTabIndex;

  final List<String> tabTitles = const ['Payments', 'Refunds', 'Payouts'];

  static const List<TransactionRecord> _paymentsList = [
    TransactionRecord(
      title: 'Business Promotion',
      date: '22 Jun 2025',
      amount: '€25.00',
      status: 'Success',
      icon: AppIcons.tickAltSvg,
      iconColor: Color(0xFF10B981),
      iconBgColor: Color(0xFFDCFCE7),
      statusColor: Color(0xFF10B981),
    ),
    TransactionRecord(
      title: 'Banner Advertisement',
      date: '18 Jun 2025',
      amount: '€15.00',
      status: 'Success',
      icon: AppIcons.tickAltSvg,
      iconColor: Color(0xFF10B981),
      iconBgColor: Color(0xFFDCFCE7),
      statusColor: Color(0xFF10B981),
    ),
    TransactionRecord(
      title: 'Boost Listing',
      date: '18 Jun 2025',
      amount: '€10.00',
      status: 'Success',
      icon: AppIcons.tickAltSvg,
      iconColor: Color(0xFF10B981),
      iconBgColor: Color(0xFFDCFCE7),
      statusColor: Color(0xFF10B981),
    ),
    TransactionRecord(
      title: 'Spotlight Package',
      date: '10 Jun 2025',
      amount: '€20.00',
      status: 'Success',
      icon: AppIcons.tickAltSvg,
      iconColor: Color(0xFF10B981),
      iconBgColor: Color(0xFFDCFCE7),
      statusColor: Color(0xFF10B981),
    ),
  ];

  static const List<TransactionRecord> _refundsList = [
    TransactionRecord(
      title: 'Cancelled Ad Boost',
      date: '04 Jun 2025',
      amount: '€10.00',
      status: 'Refunded',
      icon: AppIcons.restartSvg,
      iconColor: Color(0xFF3B82F6),
      iconBgColor: Color(0xFFDBEAFE),
      statusColor: Color(0xFF2563EB),
    ),
  ];

  static const List<TransactionRecord> _payoutsList = [
    TransactionRecord(
      title: 'Bank Transfer Payout',
      date: '01 Jun 2025',
      amount: '€450.00',
      status: 'Completed',
      icon: AppIcons.bank22,
      iconColor: Color(0xFF8B5CF6),
      iconBgColor: Color(0xFFF5F3FF),
      statusColor: Color(0xFF7C3AED),
    ),
    TransactionRecord(
      title: 'Monthly Earnings Payout',
      date: '01 May 2025',
      amount: '€520.00',
      status: 'Completed',
      icon: AppIcons.bank22,
      iconColor: Color(0xFF8B5CF6),
      iconBgColor: Color(0xFFF5F3FF),
      statusColor: Color(0xFF7C3AED),
    ),
  ];

  List<TransactionRecord> get paymentsList => _paymentsList;
  List<TransactionRecord> get refundsList => _refundsList;
  List<TransactionRecord> get payoutsList => _payoutsList;

  List<TransactionRecord> get currentList {
    switch (_selectedTabIndex) {
      case 0:
        return _paymentsList;
      case 1:
        return _refundsList;
      case 2:
        return _payoutsList;
      default:
        return _paymentsList;
    }
  }

  void selectTab(int index) {
    _selectedTabIndex = index;
    notifyListeners();
  }
}
