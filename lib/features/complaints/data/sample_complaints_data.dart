import 'package:flutter/material.dart';
import '../domain/models/complaint_model.dart';

final List<ComplaintModel> mockComplaints = [
  ComplaintModel(
    id: "comp-101",
    complaintNumber: "NOA-2026-00104",
    title: "Drinking water pipeline burst causing heavy road flooding",
    description:
        "Main underground drinking water supply pipe has fractured at 2nd Avenue intersection. Clean drinking water is gushing into the road and creating traffic blockage.",
    descriptionTa:
        "2வது அவென்யூ சந்திப்பில் முக்கிய குடிநீர் குழாய் உடைந்து பெருமளவில் குடிநீர் வீணாகி சாலையில் தேங்கி நிற்கிறது.",
    category: "water_supply",
    categoryLabel: "Water Supply",
    categoryLabelTa: "குடிநீர் வழங்கல்",
    priority: ComplaintPriority.critical,
    status: ComplaintStatus.inProgress,
    departmentId: "dept-wsd",
    departmentName: "Metro Water & Supply Board",
    departmentNameTa: "குடிநீர் வழங்கல் வாரியம்",
    assignedOfficerName: "Er. K. Sivakumar (AE-Water)",
    assignedOfficerPhone: "+91 94440 12345",
    citizenName: "Priya Ramanathan",
    citizenPhone: "+91 98765 43210",
    address: "Plot 42, 2nd Avenue, Anna Nagar East, Chennai",
    wardNumber: "Ward 102",
    zone: "Zone 5 (Anna Nagar)",
    city: "Chennai",
    latitude: 13.0850,
    longitude: 80.2101,
    createdAt: DateTime.now().subtract(const Duration(hours: 3, minutes: 15)),
    slaDeadline: DateTime.now().add(const Duration(hours: 9)),
    aiConfidence: 0.96,
    aiSummary:
        "Pipeline rupture identified with severe water wastage hazard. Escalated directly to Metro Water Rapid Response.",
    aiSummaryTa:
        "குடிநீர் குழாய் வெடிப்பு கண்டறியப்பட்டு குடிநீர் வாரிய துரித மீட்புக் குழுவிற்கு பரிந்துரைக்கப்பட்டது.",
    initialPhotoUrls: [
      "https://images.unsplash.com/photo-1541888946425-d0fbb18f15f9?w=600&auto=format&fit=crop&q=60",
    ],
    timeline: [
      ComplaintTimelineEvent(
        title: "Complaint Lodged by Citizen",
        description: "Submitted with GPS location and photo evidence.",
        timestamp:
            DateTime.now().subtract(const Duration(hours: 3, minutes: 15)),
        actorName: "Priya Ramanathan",
        actorRole: "Citizen",
        icon: Icons.edit_note,
      ),
      ComplaintTimelineEvent(
        title: "AI NLP Triage & Department Assignment",
        description:
            "Classified as Water Supply with 96% confidence. Priority set to Critical due to flooding impact.",
        timestamp:
            DateTime.now().subtract(const Duration(hours: 3, minutes: 10)),
        actorName: "Namma Ooru AI Engine",
        actorRole: "Automated System",
        icon: Icons.auto_awesome,
      ),
      ComplaintTimelineEvent(
        title: "Work Order Dispatched to Field Crew",
        description:
            "Assigned to Er. K. Sivakumar and crew deployed with valve isolation gear.",
        timestamp:
            DateTime.now().subtract(const Duration(hours: 1, minutes: 40)),
        actorName: "Zonal Executive Engineer",
        actorRole: "Municipal Administrator",
        icon: Icons.engineering,
      ),
    ],
  ),
  ComplaintModel(
    id: "comp-102",
    complaintNumber: "NOA-2026-00089",
    title: "Commercial garbage bin overflowing on Usman Road",
    description:
        "Solid waste bin near vegetable and fruit vendors has been overflowing for 2 days. Animals scattering plastic waste and strong foul odor spreading across shopping street.",
    descriptionTa:
        "உஸ்மான் சாலை காய்கறி அங்காடி அருகில் உள்ள குப்பைத்தொட்டி நிரம்பி 2 நாட்களாக அள்ளப்படாமல் உள்ளது.",
    category: "garbage_collection",
    categoryLabel: "Garbage Collection",
    categoryLabelTa: "திடக்கழிவு மேலாண்மை",
    priority: ComplaintPriority.high,
    status: ComplaintStatus.underReview,
    departmentId: "dept-swm",
    departmentName: "Solid Waste Management",
    departmentNameTa: "திடக்கழிவு மேலாண்மைத் துறை",
    assignedOfficerName: "Thiru M. Arumugam (Sanitary Inspector)",
    citizenName: "R. Venkatesh",
    citizenPhone: "+91 94441 23456",
    address: "Opposite Pothy's, Usman Road, T. Nagar, Chennai",
    wardNumber: "Ward 114",
    zone: "Zone 8 (Teynampet)",
    city: "Chennai",
    latitude: 13.0405,
    longitude: 80.2337,
    createdAt: DateTime.now().subtract(const Duration(hours: 18)),
    slaDeadline: DateTime.now().add(const Duration(hours: 6)),
    aiConfidence: 0.94,
    aiSummary:
        "Commercial organic & plastic waste accumulation posing public health nuisance. Compactor truck dispatch required.",
    aiSummaryTa:
        "வணிக வளாகக் குப்பை தேக்கம் மற்றும் துர்நாற்றம். உடனடியாக குப்பை அள்ளும் வாகனம் தேவை.",
    initialPhotoUrls: [
      "https://images.unsplash.com/photo-1532996122724-e3c354a0b15b?w=600&auto=format&fit=crop&q=60",
    ],
    timeline: [
      ComplaintTimelineEvent(
        title: "Complaint Registered",
        description: "Reported via mobile app with image upload.",
        timestamp: DateTime.now().subtract(const Duration(hours: 18)),
        actorName: "R. Venkatesh",
        actorRole: "Citizen",
        icon: Icons.edit_note,
      ),
      ComplaintTimelineEvent(
        title: "Classified to Solid Waste Dept",
        description:
            "High priority assigned based on commercial zone traffic density.",
        timestamp:
            DateTime.now().subtract(const Duration(hours: 17, minutes: 50)),
        actorName: "Namma Ooru AI Engine",
        actorRole: "Automated System",
        icon: Icons.auto_awesome,
      ),
    ],
  ),
  ComplaintModel(
    id: "comp-103",
    complaintNumber: "NOA-2026-00052",
    title: "Deep pothole dangerous for two-wheelers on Cross Cut Road",
    description:
        "After recent monsoon shower, a 1.5 ft crater has opened up on Cross Cut Road. Several two-wheeler riders have lost balance during evening peak hours.",
    descriptionTa:
        "மழைக்கு பின் கிராஸ் கட் சாலையில் ஏற்பட்ட பெரிய பள்ளத்தால் இருசக்கர வாகனங்கள் விபத்துக்குள்ளாகின்றன.",
    category: "road_damage",
    categoryLabel: "Road Damage & Potholes",
    categoryLabelTa: "சாலை சேதங்கள்",
    priority: ComplaintPriority.high,
    status: ComplaintStatus.resolved,
    departmentId: "dept-eng",
    departmentName: "Highways & Roads Engineering",
    departmentNameTa: "சாலைகள் மற்றும் பாலங்கள் துறை",
    assignedOfficerName: "Er. N. Murugan",
    assignedOfficerPhone: "+91 98401 55667",
    citizenName: "Deepak Sundaram",
    citizenPhone: "+91 97910 88990",
    address: "Near Power House Junction, Cross Cut Road, Gandhipuram",
    wardNumber: "Ward 45",
    zone: "Central Zone",
    city: "Coimbatore",
    latitude: 11.0168,
    longitude: 76.9558,
    createdAt: DateTime.now().subtract(const Duration(days: 3, hours: 4)),
    resolvedAt: DateTime.now().subtract(const Duration(hours: 5)),
    resolutionNotes:
        "Cold mix asphalt patching completed with roller compaction. Road surface level restored safely.",
    aiConfidence: 0.98,
    aiSummary:
        "Hazardous pothole classified on arterial commercial corridor. Road Engineering patched with asphalt.",
    aiSummaryTa:
        "ஆபத்தான சாலைப் பள்ளம் தார் கலவை கொண்டு சீரமைக்கப்பட்டு சமன்படுத்தப்பட்டது.",
    initialPhotoUrls: [
      "https://images.unsplash.com/photo-1515162816999-a0c47dc192f7?w=600&auto=format&fit=crop&q=60",
    ],
    resolutionPhotoUrls: [
      "https://images.unsplash.com/photo-1544620347-c4fd4a3d5957?w=600&auto=format&fit=crop&q=60",
    ],
    timeline: [
      ComplaintTimelineEvent(
        title: "Complaint Created",
        description: "Reported with photos of dangerous crater.",
        timestamp: DateTime.now().subtract(const Duration(days: 3, hours: 4)),
        actorName: "Deepak Sundaram",
        actorRole: "Citizen",
        icon: Icons.edit_note,
      ),
      ComplaintTimelineEvent(
        title: "Inspected by Road Inspector",
        description:
            "Field measurement confirmed depth of 45 cm. Work order issued to hot-mix contractor.",
        timestamp: DateTime.now().subtract(const Duration(days: 2)),
        actorName: "Er. N. Murugan",
        actorRole: "Field Officer",
        icon: Icons.search,
      ),
      ComplaintTimelineEvent(
        title: "Repair Work Executed & Verified",
        description:
            "Bituminous patching applied and compacted. Before & after photographic proof uploaded.",
        timestamp: DateTime.now().subtract(const Duration(hours: 5)),
        actorName: "Er. N. Murugan",
        actorRole: "Field Officer",
        icon: Icons.check_circle,
      ),
      ComplaintTimelineEvent(
        title: "Complaint Closed with Resolution",
        description:
            "Citizen notified via SMS and App. Resolution feedback requested.",
        timestamp:
            DateTime.now().subtract(const Duration(hours: 4, minutes: 50)),
        actorName: "Central Grievance Cell",
        actorRole: "Municipal Administrator",
        icon: Icons.verified,
      ),
    ],
  ),
  ComplaintModel(
    id: "comp-104",
    complaintNumber: "NOA-2026-00041",
    title: "Four consecutive LED streetlights not functioning",
    description:
        "Entire residential stretch on 7th Cross Street is pitch dark since Monday. Seniors and women feeling unsafe walking after 7 PM.",
    descriptionTa:
        "7வது குறுக்குத் தெருவில் உள்ள நான்கு தெருவிளக்குகள் எரியாமல் இருட்டாக உள்ளது.",
    category: "streetlights",
    categoryLabel: "Streetlights",
    categoryLabelTa: "தெருவிளக்குகள்",
    priority: ComplaintPriority.medium,
    status: ComplaintStatus.assigned,
    departmentId: "dept-ele",
    departmentName: "Public Lighting & Electrical",
    departmentNameTa: "மின் விளக்குகள் பிரிவு",
    assignedOfficerName: "Thiru S. Balaji (Electrician Line-Inspector)",
    citizenName: "Meenakshi Sundaram",
    citizenPhone: "+91 94432 11223",
    address: "7th Cross Street, North Extension, Thillai Nagar",
    wardNumber: "Ward 32",
    zone: "Zone 3",
    city: "Tiruchirappalli",
    latitude: 10.8250,
    longitude: 78.6856,
    createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
    slaDeadline: DateTime.now().add(const Duration(hours: 22)),
    aiConfidence: 0.95,
    aiSummary:
        "Phase power failure or driver burnout on 4 LED fixtures in residential ward. Line technician assigned.",
    aiSummaryTa:
        "நான்கு எல்.இ.டி விளக்குகள் எரியவில்லை. மின்வாரிய ஆய்வாளர் நியமிக்கப்பட்டுள்ளார்.",
    timeline: [
      ComplaintTimelineEvent(
        title: "Complaint Lodged",
        description: "Submitted through voice input in Tamil.",
        timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
        actorName: "Meenakshi Sundaram",
        actorRole: "Citizen",
        icon: Icons.record_voice_over,
      ),
      ComplaintTimelineEvent(
        title: "Assigned to Electrical Division",
        description: "Work allocated to Ward 32 Maintenance Crew.",
        timestamp: DateTime.now().subtract(const Duration(hours: 12)),
        actorName: "Thiru S. Balaji",
        actorRole: "Field Officer",
        icon: Icons.assignment_ind,
      ),
    ],
  ),
  ComplaintModel(
    id: "comp-105",
    complaintNumber: "NOA-2026-00018",
    title: "Open drainage manhole cover displaced near primary school",
    description:
        "Heavy concrete manhole slab was broken by a water tanker. Raw sewage exposed right opposite Corporation Primary School gate.",
    descriptionTa:
        "மாநகராட்சி தொடக்கப்பள்ளி அருகில் பாதாள சாக்கடை மூடி உடைந்து திறந்த நிலையில் உள்ளது. குழந்தைகளுக்கு பேராபத்து.",
    category: "drainage",
    categoryLabel: "Stormwater & Drainage",
    categoryLabelTa: "மழைநீர் வடிகால் & சாக்கடை",
    priority: ComplaintPriority.critical,
    status: ComplaintStatus.inProgress,
    departmentId: "dept-drn",
    departmentName: "Stormwater & Drainage",
    departmentNameTa: "மழைநீர் வடிகால் மற்றும் பாதாள சாக்கடை",
    assignedOfficerName: "Er. G. Ravichandran",
    assignedOfficerPhone: "+91 94443 33445",
    citizenName: "Anand Kumar",
    citizenPhone: "+91 98412 99887",
    address: "Opp. Corporation Primary School, West Tower Street",
    wardNumber: "Ward 18",
    zone: "South Zone",
    city: "Madurai",
    latitude: 9.9195,
    longitude: 78.1193,
    createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    slaDeadline: DateTime.now().add(const Duration(hours: 4)),
    aiConfidence: 0.99,
    aiSummary:
        "Critical pedestrian & school hazard. Immediate barricading and high-density FRP cover replacement instructed.",
    aiSummaryTa:
        "பள்ளி அருகில் திறந்த சாக்கடை மூடி பேராபத்து. உடனடியாக தடுப்புகள் அமைத்து புதிய மூடி பொருத்த உத்தரவு.",
    timeline: [
      ComplaintTimelineEvent(
        title: "High Urgency Complaint Registered",
        description:
            "AI identified safety keyword 'School' + 'Open Manhole' -> auto-flagged CRITICAL.",
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        actorName: "Anand Kumar",
        actorRole: "Citizen",
        icon: Icons.warning_amber,
      ),
      ComplaintTimelineEvent(
        title: "Emergency Warning Barricades Placed",
        description:
            "Red safety cones and barricade tape erected to prevent student accidents.",
        timestamp: DateTime.now().subtract(const Duration(minutes: 45)),
        actorName: "Er. G. Ravichandran",
        actorRole: "Field Officer",
        icon: Icons.shield,
      ),
    ],
  ),
];
