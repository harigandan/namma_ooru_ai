import 'package:flutter/material.dart';

enum ComplaintStatus {
  submitted,
  underReview,
  assigned,
  inProgress,
  resolved,
  closed,
  reopened,
}

enum ComplaintPriority {
  low,
  medium,
  high,
  critical,
}

class ComplaintTimelineEvent {
  final String title;
  final String description;
  final DateTime timestamp;
  final String actorName;
  final String actorRole;
  final IconData icon;

  const ComplaintTimelineEvent({
    required this.title,
    required this.description,
    required this.timestamp,
    required this.actorName,
    required this.actorRole,
    this.icon = Icons.check_circle_outline,
  });
}

class ComplaintModel {
  final String id;
  final String complaintNumber;
  final String title;
  final String description;
  final String? descriptionTa;
  final String category;
  final String categoryLabel;
  final String categoryLabelTa;
  final ComplaintPriority priority;
  final ComplaintStatus status;
  final String departmentId;
  final String departmentName;
  final String departmentNameTa;
  final String? assignedOfficerName;
  final String? assignedOfficerPhone;
  final String citizenName;
  final String citizenPhone;
  final String address;
  final String wardNumber;
  final String zone;
  final String city;
  final double latitude;
  final double longitude;
  final DateTime createdAt;
  final DateTime? slaDeadline;
  final DateTime? resolvedAt;
  final String? resolutionNotes;
  final List<String> initialPhotoUrls;
  final List<String> resolutionPhotoUrls;
  final double aiConfidence;
  final String aiSummary;
  final String? aiSummaryTa;
  final List<ComplaintTimelineEvent> timeline;

  const ComplaintModel({
    required this.id,
    required this.complaintNumber,
    required this.title,
    required this.description,
    this.descriptionTa,
    required this.category,
    required this.categoryLabel,
    required this.categoryLabelTa,
    required this.priority,
    required this.status,
    required this.departmentId,
    required this.departmentName,
    required this.departmentNameTa,
    this.assignedOfficerName,
    this.assignedOfficerPhone,
    required this.citizenName,
    required this.citizenPhone,
    required this.address,
    required this.wardNumber,
    required this.zone,
    this.city = "Chennai",
    required this.latitude,
    required this.longitude,
    required this.createdAt,
    this.slaDeadline,
    this.resolvedAt,
    this.resolutionNotes,
    this.initialPhotoUrls = const [],
    this.resolutionPhotoUrls = const [],
    required this.aiConfidence,
    required this.aiSummary,
    this.aiSummaryTa,
    this.timeline = const [],
  });

  String get statusString {
    switch (status) {
      case ComplaintStatus.submitted:
        return 'submitted';
      case ComplaintStatus.underReview:
        return 'under_review';
      case ComplaintStatus.assigned:
        return 'assigned';
      case ComplaintStatus.inProgress:
        return 'in_progress';
      case ComplaintStatus.resolved:
        return 'resolved';
      case ComplaintStatus.closed:
        return 'closed';
      case ComplaintStatus.reopened:
        return 'reopened';
    }
  }

  String get priorityString {
    switch (priority) {
      case ComplaintPriority.critical:
        return 'critical';
      case ComplaintPriority.high:
        return 'high';
      case ComplaintPriority.medium:
        return 'medium';
      case ComplaintPriority.low:
        return 'low';
    }
  }

  factory ComplaintModel.fromJson(Map<String, dynamic> json) {
    ComplaintStatus parseStatus(String? s) {
      switch (s?.toLowerCase()) {
        case 'submitted':
          return ComplaintStatus.submitted;
        case 'under_review':
          return ComplaintStatus.underReview;
        case 'assigned':
          return ComplaintStatus.assigned;
        case 'in_progress':
          return ComplaintStatus.inProgress;
        case 'resolved':
          return ComplaintStatus.resolved;
        case 'closed':
          return ComplaintStatus.closed;
        case 'reopened':
          return ComplaintStatus.reopened;
        default:
          return ComplaintStatus.submitted;
      }
    }

    ComplaintPriority parsePriority(String? p) {
      switch (p?.toLowerCase()) {
        case 'critical':
          return ComplaintPriority.critical;
        case 'high':
          return ComplaintPriority.high;
        case 'medium':
          return ComplaintPriority.medium;
        case 'low':
        default:
          return ComplaintPriority.low;
      }
    }

    String category = json['category'] ?? 'other';
    String categoryLabel = category.replaceAll('_', ' ').toUpperCase();
    String categoryLabelTa = category;

    if (category == 'water_supply') {
      categoryLabel = 'Water Supply';
      categoryLabelTa = 'குடிநீர் வழங்கல்';
    } else if (category == 'garbage_collection') {
      categoryLabel = 'Garbage Collection';
      categoryLabelTa = 'திடக்கழிவு மேலாண்மை';
    } else if (category == 'road_damage') {
      categoryLabel = 'Road Damage & Potholes';
      categoryLabelTa = 'சாலை சேதங்கள்';
    } else if (category == 'streetlights') {
      categoryLabel = 'Streetlights';
      categoryLabelTa = 'தெருவிளக்குகள்';
    } else if (category == 'drainage') {
      categoryLabel = 'Stormwater & Drainage';
      categoryLabelTa = 'மழைநீர் வடிகால்';
    }

    DateTime created =
        DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now();

    return ComplaintModel(
      id: json['id'] ?? '',
      complaintNumber: json['complaint_number'] ?? 'NOA-2026',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      descriptionTa: json['description_ta'],
      category: category,
      categoryLabel: categoryLabel,
      categoryLabelTa: categoryLabelTa,
      priority: parsePriority(json['priority']),
      status: parseStatus(json['status']),
      departmentId: json['department_id'] ?? '',
      departmentName: 'Municipal Department',
      departmentNameTa: 'நகராட்சித் துறை',
      assignedOfficerName:
          json['assigned_officer_id'] != null ? 'Assigned Field Officer' : null,
      citizenName: 'Registered Citizen',
      citizenPhone: '+91 98765 43210',
      address: json['address'] ?? 'Tamil Nadu',
      wardNumber: json['ward_number'] ?? 'Ward 102',
      zone: json['zone'] ?? 'Zone 5',
      city: 'Chennai',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 13.0827,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 80.2707,
      createdAt: created,
      resolutionNotes: json['resolution_notes'],
      aiConfidence: 0.95,
      aiSummary: 'Classified by Namma Ooru AI NLP Engine.',
      timeline: [
        ComplaintTimelineEvent(
          title: 'Complaint Registered',
          description: 'Ticket generated in the municipal registry.',
          timestamp: created,
          actorName: 'Citizen',
          actorRole: 'Citizen',
          icon: Icons.edit_note,
        ),
      ],
    );
  }
}
