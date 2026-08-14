import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Model for farm report
class FarmReportModel {
  final String reportType; // '365_day_plan' or 'crop_recommendation'
  final Map<String, dynamic> data;

  FarmReportModel({
    required this.reportType,
    required this.data,
  });

  FarmReportModel copyWith({
    String? reportType,
    Map<String, dynamic>? data,
  }) {
    return FarmReportModel(
      reportType: reportType ?? this.reportType,
      data: data ?? this.data,
    );
  }
}

/// State notifier for managing farm report
class FarmReportNotifier extends StateNotifier<FarmReportModel?> {
  FarmReportNotifier() : super(null);

  /// Set the report data
  void setReport(String type, Map<String, dynamic> reportData) {
    state = FarmReportModel(
      reportType: type,
      data: reportData,
    );
  }

  /// Clear the report
  void clearReport() {
    state = null;
  }
}

/// Provider for farm report notifier
final farmReportNotifierProvider =
    StateNotifierProvider<FarmReportNotifier, FarmReportModel?>((ref) {
      return FarmReportNotifier();
    });

/// Provider for form visibility
final showFarmReportFormProvider = StateProvider<bool>((ref) => false);

/// Provider for loading state
final farmReportLoadingProvider = StateProvider<bool>((ref) => false);
