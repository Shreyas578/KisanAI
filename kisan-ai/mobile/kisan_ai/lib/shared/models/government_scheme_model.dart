import 'dart:convert';

class GovernmentScheme {
  final String id;
  final String title;
  final String description;
  final String implementingAgency; // e.g., "Government of India", "State Government"
  final String schemeType; // "subsidy", "loan", "insurance", "training", "infrastructure"
  final List<String> eligibleCropTypes; // e.g., ["rice", "wheat", "cotton"]
  final List<String> eligibleFarmerTypes; // e.g., ["small", "marginal", "women", "sc_st"]
  final double? financialBenefit; // amount in INR if applicable
  final String benefitType; // "amount_per_acre", "percentage_subsidy", "fixed_amount"
  final DateTime applicationStartDate;
  final DateTime? applicationEndDate;
  final DateTime? schemeStartDate;
  final DateTime? schemeEndDate;
  final String applicationProcess; // brief description of how to apply
  final String requiredDocuments; // comma-separated list or JSON string
  final String contactInformation; // phone, email, website
  final String officialWebsite; // URL for more details
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String rawEligibilityCriteria;
  final String rawBenefits;

  GovernmentScheme({
    required this.id,
    required this.title,
    required this.description,
    required this.implementingAgency,
    required this.schemeType,
    required this.eligibleCropTypes,
    required this.eligibleFarmerTypes,
    this.financialBenefit,
    required this.benefitType,
    required this.applicationStartDate,
    this.applicationEndDate,
    this.schemeStartDate,
    this.schemeEndDate,
    required this.applicationProcess,
    required this.requiredDocuments,
    required this.contactInformation,
    required this.officialWebsite,
    required this.isActive,
    required this.createdAt,
    this.updatedAt,
    required this.rawEligibilityCriteria,
    required this.rawBenefits,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'implementingAgency': implementingAgency,
        'schemeType': schemeType,
        'eligibleCropTypes': eligibleCropTypes,
        'eligibleFarmerTypes': eligibleFarmerTypes,
        'financialBenefit': financialBenefit,
        'benefitType': benefitType,
        'applicationStartDate': applicationStartDate.toIso8601String(),
        'applicationEndDate': applicationEndDate?.toIso8601String(),
        'schemeStartDate': schemeStartDate?.toIso8601String(),
        'schemeEndDate': schemeEndDate?.toIso8601String(),
        'applicationProcess': applicationProcess,
        'requiredDocuments': requiredDocuments,
        'contactInformation': contactInformation,
        'officialWebsite': officialWebsite,
        'isActive': isActive,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
        'rawEligibilityCriteria': rawEligibilityCriteria,
        'rawBenefits': rawBenefits,
      };

  factory GovernmentScheme.fromJson(Map<String, dynamic> json) {
    // Parse eligibility criteria (which comes as JSON from DB)
    List<String> farmerTypes = [];
    String rawElig = 'Not specified';
    
    if (json['eligibility_criteria'] != null) {
      final criteria = json['eligibility_criteria'];
      if (criteria is String) {
        rawElig = criteria.replaceAll('"', '');
        try {
          final parsed = jsonDecode(criteria);
          if (parsed is Map && parsed['farmer_types'] != null) {
            farmerTypes = List<String>.from(parsed['farmer_types']);
          } else if (parsed is List) {
            farmerTypes = List<String>.from(parsed);
          }
        } catch (_) {}
      } else if (criteria is Map) {
        if (criteria['farmer_types'] != null) {
          farmerTypes = List<String>.from(criteria['farmer_types']);
        }
        rawElig = jsonEncode(criteria);
      } else if (criteria is List) {
        farmerTypes = List<String>.from(criteria);
        rawElig = farmerTypes.join(', ');
      }
    }

    String rawBen = 'Not specified';
    if (json['benefits'] != null) {
      final ben = json['benefits'];
      if (ben is String) {
        rawBen = ben.replaceAll('"', '').replaceAll('?', '₹');
      } else if (ben is List) {
        rawBen = List<String>.from(ben).join(', ');
      } else {
        rawBen = jsonEncode(ben);
      }
    }

    return GovernmentScheme(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? json['name'] ?? 'Untitled Scheme',
      description: json['description'] ?? '',
      implementingAgency: json['implementingAgency'] ?? json['agency'] ?? 'Govt. of India',
      schemeType: json['schemeType'] ?? json['scheme_type'] ?? 'General',
      eligibleCropTypes: json['eligibleCropTypes'] != null ? List<String>.from(json['eligibleCropTypes']) : [],
      eligibleFarmerTypes: farmerTypes.isEmpty ? ['All Farmers'] : farmerTypes,
      financialBenefit: json['financialBenefit'] != null ? double.tryParse(json['financialBenefit'].toString()) : null,
      benefitType: json['benefitType'] ?? 'other',
      applicationStartDate: json['applicationStartDate'] != null ? DateTime.parse(json['applicationStartDate']) : DateTime.now(),
      applicationEndDate: json['applicationEndDate'] != null ? DateTime.parse(json['applicationEndDate']) : null,
      schemeStartDate: json['schemeStartDate'] != null ? DateTime.parse(json['schemeStartDate']) : null,
      schemeEndDate: json['schemeEndDate'] != null ? DateTime.parse(json['schemeEndDate']) : null,
      applicationProcess: json['applicationProcess'] ?? json['application_process'] ?? 'Apply online or via local CSC',
      requiredDocuments: json['requiredDocuments'] ?? json['required_documents'] ?? 'Aadhar Card, Land Record',
      contactInformation: json['contactInformation'] ?? json['contact_info'] ?? '1800-180-1551 (Kisan Call Center)',
      officialWebsite: json['officialWebsite'] ?? json['website_url'] ?? 'https://agricoop.nic.in/',
      isActive: json['isActive'] ?? json['is_active'] == 1 ?? (json['is_active'] == true) ?? true,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : (json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now()),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : (json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null),
      rawEligibilityCriteria: rawElig,
      rawBenefits: rawBen,
    );
  }
}

class FarmerSchemeApplication {
  final String id;
  final String farmerId;
  final String schemeId;
  final DateTime applicationDate;
  final String status; // "draft", "submitted", "under_review", "approved", "rejected", "disbursed"
  final Map<String, dynamic>? applicationData; // form data submitted
  final String? approvalReference; // reference number if approved
  final double? approvedAmount; // amount approved if applicable
  final DateTime? approvalDate;
  final DateTime? disbursementDate;
  final String? remarks; // from reviewing officer
  final String? rejectedReason; // if rejected
  final DateTime createdAt;
  final DateTime? updatedAt;
  
  FarmerSchemeApplication({
    required this.id,
    required this.farmerId,
    required this.schemeId,
    required this.applicationDate,
    required this.status,
    this.applicationData,
    this.approvalReference,
    this.approvedAmount,
    this.approvalDate,
    this.disbursementDate,
    this.remarks,
    this.rejectedReason,
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'farmerId': farmerId,
        'schemeId': schemeId,
        'applicationDate': applicationDate.toIso8601String(),
        'status': status,
        'applicationData': applicationData,
        'approvalReference': approvalReference,
        'approvedAmount': approvedAmount,
        'approvalDate': approvalDate?.toIso8601String(),
        'disbursementDate': disbursementDate?.toIso8601String(),
        'remarks': remarks,
        'rejectedReason': rejectedReason,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
      };

  factory FarmerSchemeApplication.fromJson(Map<String, dynamic> json) => FarmerSchemeApplication(
        id: json['id'],
        farmerId: json['farmerId'],
        schemeId: json['schemeId'],
        applicationDate: DateTime.parse(json['applicationDate']),
        status: json['status'],
        applicationData: json['applicationData'],
        approvalReference: json['approvalReference'],
        approvedAmount: json['approvedAmount'],
        approvalDate: json['approvalDate'] != null ? DateTime.parse(json['approvalDate']) : null,
        disbursementDate: json['disbursementDate'] != null ? DateTime.parse(json['disbursementDate']) : null,
        remarks: json['remarks'],
        rejectedReason: json['rejectedReason'],
        createdAt: DateTime.parse(json['createdAt']),
        updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      );
}
