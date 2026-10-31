import asyncio
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from app.database.session import AsyncSessionLocal, engine
from app.models.base import Base
import app.models  # register all models in metadata
from app.models.user import User, CitizenProfile
from app.models.department import Department, FieldOfficer
from app.models.complaint import Complaint, ComplaintStatusHistory
from app.models.ward import Municipality, Zone, Ward
from app.core.security import get_password_hash

DEPARTMENTS_SEED = [
    {
        "name": "Solid Waste Management",
        "name_ta": "திடக்கழிவு மேலாண்மைத் துறை",
        "code": "SWM",
        "description": "Handles household garbage, market clearing, and recycling operations.",
        "head_name": "Dr. K. Anbazhagan",
        "contact_phone": "044-25619200",
    },
    {
        "name": "Highways & Roads Engineering",
        "name_ta": "சாலைகள் மற்றும் பாலங்கள் துறை",
        "code": "ENG",
        "description": "Responsible for asphalt paving, potholes, speed breakers, and sidewalk maintenance.",
        "head_name": "Er. S. Murugesan",
        "contact_phone": "044-25619300",
    },
    {
        "name": "Metro Water & Supply Board",
        "name_ta": "குடிநீர் வழங்கல் வாரியம்",
        "code": "WSD",
        "description": "Oversees drinking water distribution, pipeline maintenance, and tanker supply.",
        "head_name": "Tmt. R. Lakshmi",
        "contact_phone": "044-45674567",
    },
    {
        "name": "Stormwater & Drainage",
        "name_ta": "மழைநீர் வடிகால் மற்றும் பாதாள சாக்கடை",
        "code": "DRN",
        "description": "Manages underground sewer networks, monsoon stormwater canals, and desilting.",
        "head_name": "Er. V. Sundar",
        "contact_phone": "044-25619400",
    },
    {
        "name": "Public Lighting & Electrical",
        "name_ta": "மின் விளக்குகள் மற்றும் மின் பிரிவு",
        "code": "ELE",
        "description": "Maintains LED streetlights, high-mast lamps, and electrical safety on streets.",
        "head_name": "Thiru P. Raman",
        "contact_phone": "044-25619500",
    },
    {
        "name": "Public Health & Sanitation",
        "name_ta": "பொது சுகாதாரம் மற்றும் துப்புரவு",
        "code": "PUB_HEALTH",
        "description": "Public restrooms, mosquito eradication fogging, food safety, and veterinary health.",
        "head_name": "Dr. M. Senthamizhan",
        "contact_phone": "044-25619600",
    },
]

ZONES_AND_WARDS_SEED = [
    {
        "name": "Zone 5 (Royapuram)",
        "name_ta": "மண்டலம் 5 (ராயபுரம்)",
        "zone_number": 5,
        "code": "Z05",
        "wards": [
            {"number": "Ward 49", "name": "Royapuram North", "name_ta": "ராயபுரம் வடக்கு", "lat": 13.1075, "lng": 80.2936},
            {"number": "Ward 50", "name": "Old Washermanpet", "name_ta": "பழைய வண்ணாரப்பேட்டை", "lat": 13.1118, "lng": 80.2882},
            {"number": "Ward 51", "name": "Seven Wells", "name_ta": "ஏழு கிணறு", "lat": 13.0967, "lng": 80.2833},
            {"number": "Ward 52", "name": "George Town", "name_ta": "ஜார்ஜ் டவுன்", "lat": 13.0921, "lng": 80.2867},
            {"number": "Ward 53", "name": "Harbour Port", "name_ta": "துறைமுகம் பகுதி", "lat": 13.0850, "lng": 80.2910},
        ],
    },
    {
        "name": "Zone 8 (Anna Nagar)",
        "name_ta": "மண்டலம் 8 (அண்ணா நகர்)",
        "zone_number": 8,
        "code": "Z08",
        "wards": [
            {"number": "Ward 101", "name": "Anna Nagar East", "name_ta": "அண்ணா நகர் கிழக்கு", "lat": 13.0870, "lng": 80.2180},
            {"number": "Ward 102", "name": "Anna Nagar West", "name_ta": "அண்ணா நகர் மேற்கு", "lat": 13.0850, "lng": 80.2101},
            {"number": "Ward 103", "name": "Shenoy Nagar", "name_ta": "செனாய் நகர்", "lat": 13.0780, "lng": 80.2250},
            {"number": "Ward 104", "name": "Aminjikarai", "name_ta": "அமைந்தகரை", "lat": 13.0720, "lng": 80.2190},
            {"number": "Ward 105", "name": "Arumbakkam", "name_ta": "அரும்பாக்கம்", "lat": 13.0680, "lng": 80.2080},
        ],
    },
    {
        "name": "Zone 10 (Kodambakkam / T. Nagar)",
        "name_ta": "மண்டலம் 10 (கோடம்பாக்கம் / தி. நகர்)",
        "zone_number": 10,
        "code": "Z10",
        "wards": [
            {"number": "Ward 114", "name": "T. Nagar North", "name_ta": "தி. நகர் வடக்கு", "lat": 13.0450, "lng": 80.2350},
            {"number": "Ward 115", "name": "Usman Road Market", "name_ta": "உஸ்மான் சாலை அங்காடி", "lat": 13.0400, "lng": 80.2300},
            {"number": "Ward 128", "name": "Vadapalani Junction", "name_ta": "வடபழனி சந்திப்பு", "lat": 13.0300, "lng": 80.2150},
            {"number": "Ward 129", "name": "Ashok Nagar", "name_ta": "அசோக் நகர்", "lat": 13.0350, "lng": 80.2120},
            {"number": "Ward 130", "name": "West Mambalam", "name_ta": "மேற்கு மாம்பலம்", "lat": 13.0380, "lng": 80.2220},
        ],
    },
    {
        "name": "Zone 13 (Adyar / Velachery)",
        "name_ta": "மண்டலம் 13 (அடையாறு / வேளச்சேரி)",
        "zone_number": 13,
        "code": "Z13",
        "wards": [
            {"number": "Ward 170", "name": "Guindy Industrial Estate", "name_ta": "கிண்டி தொழிற்பேட்டை", "lat": 13.0067, "lng": 80.2030},
            {"number": "Ward 171", "name": "Adyar West", "name_ta": "அடையாறு மேற்கு", "lat": 13.0012, "lng": 80.2565},
            {"number": "Ward 172", "name": "Besant Nagar Beach", "name_ta": "பெசன்ட் நகர் கடற்கரை", "lat": 13.0003, "lng": 80.2680},
            {"number": "Ward 173", "name": "Thiruvanmiyur", "name_ta": "திருவான்மியூர்", "lat": 12.9830, "lng": 80.2594},
            {"number": "Ward 177", "name": "Velachery Main", "name_ta": "வேளச்சேரி பிரதான பகுதி", "lat": 13.0200, "lng": 80.2200},
        ],
    },
]

async def seed_data():
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)

    async with AsyncSessionLocal() as db:
        # 1. Seed Departments
        for d in DEPARTMENTS_SEED:
            res = await db.execute(select(Department).where(Department.code == d["code"]))
            if not res.scalar_one_or_none():
                dept = Department(
                    name=d["name"],
                    name_ta=d["name_ta"],
                    code=d["code"],
                    description=d["description"],
                    head_name=d["head_name"],
                    contact_phone=d["contact_phone"],
                    is_active=True,
                )
                db.add(dept)

        # 2. Seed Municipality, Zones & Wards
        muni_res = await db.execute(select(Municipality).where(Municipality.code == "GCC"))
        muni = muni_res.scalar_one_or_none()
        if not muni:
            muni = Municipality(
                name="Greater Chennai Corporation (GCC)",
                name_ta="பெருநகர சென்னை மாநகராட்சி",
                code="GCC",
                district="Chennai",
                state="Tamil Nadu",
                is_active=True,
            )
            db.add(muni)
            await db.flush()

        ward_lookup = {}
        for z_data in ZONES_AND_WARDS_SEED:
            z_res = await db.execute(select(Zone).where(Zone.code == z_data["code"]))
            zone = z_res.scalar_one_or_none()
            if not zone:
                zone = Zone(
                    municipality_id=muni.id,
                    name=z_data["name"],
                    name_ta=z_data["name_ta"],
                    zone_number=z_data["zone_number"],
                    code=z_data["code"],
                    is_active=True,
                )
                db.add(zone)
                await db.flush()

            for w_data in z_data["wards"]:
                w_res = await db.execute(select(Ward).where(Ward.ward_number == w_data["number"]))
                ward = w_res.scalar_one_or_none()
                if not ward:
                    ward = Ward(
                        zone_id=zone.id,
                        ward_number=w_data["number"],
                        ward_name=w_data["name"],
                        ward_name_ta=w_data["name_ta"],
                        center_latitude=w_data["lat"],
                        center_longitude=w_data["lng"],
                        is_active=True,
                    )
                    db.add(ward)
                    await db.flush()
                ward_lookup[w_data["number"]] = ward

        # 3. Seed Default Municipal Administrator
        admin_res = await db.execute(select(User).where(User.email == "admin@nammaooru.tn.gov.in"))
        admin_user = admin_res.scalar_one_or_none()
        if not admin_user:
            admin_user = User(
                email="admin@nammaooru.tn.gov.in",
                phone="9840012345",
                password_hash=get_password_hash("Admin@NammaOoru2026"),
                full_name="Thiru R. Senthil Kumar IAS (Commissioner)",
                role="admin",
                preferred_language="ta",
                is_active=True,
                is_verified=True,
            )
            db.add(admin_user)

        # 4. Seed Default Citizen User
        citizen_res = await db.execute(select(User).where(User.email == "citizen@example.com"))
        if not citizen_res.scalar_one_or_none():
            citizen_user = User(
                email="citizen@example.com",
                phone="9876543210",
                password_hash=get_password_hash("Citizen@12345"),
                full_name="Priya Ramanathan",
                role="citizen",
                preferred_language="ta",
                is_active=True,
                is_verified=True,
            )
            db.add(citizen_user)
            await db.flush()

            w102 = ward_lookup.get("Ward 102")
            profile = CitizenProfile(
                user_id=citizen_user.id,
                city="Chennai",
                municipality_name="Greater Chennai Corporation",
                zone="Zone 8 (Anna Nagar)",
                ward_id=w102.id if w102 else None,
                ward_number="Ward 102",
                address="2nd Avenue, Anna Nagar, Chennai",
                latitude=13.0850,
                longitude=80.2101,
            )
            db.add(profile)

        # 5. Seed Default Field Officer User
        officer_res = await db.execute(select(User).where(User.email == "officer@nammaooru.tn.gov.in"))
        if not officer_res.scalar_one_or_none():
            officer_user = User(
                email="officer@nammaooru.tn.gov.in",
                phone="9444012345",
                password_hash=get_password_hash("Officer@12345"),
                full_name="Er. K. Sivakumar (AE-Water)",
                role="field_officer",
                preferred_language="ta",
                is_active=True,
                is_verified=True,
            )
            db.add(officer_user)
            await db.flush()

            water_dept_res = await db.execute(select(Department).where(Department.code == "WSD"))
            water_dept = water_dept_res.scalar_one_or_none()
            if water_dept:
                officer_profile = FieldOfficer(
                    user_id=officer_user.id,
                    department_id=water_dept.id,
                    employee_id="GCC-WSD-104",
                    designation="Assistant Executive Engineer",
                    assigned_zone="Zone 8 (Anna Nagar)",
                    is_available=True,
                )
                db.add(officer_profile)

        # 6. Seed Additional Standard Development Accounts requested for testing
        # 6A. Admin: admin@nammaooru.ai / Admin@123
        std_admin_res = await db.execute(select(User).where(User.email == "admin@nammaooru.ai"))
        if not std_admin_res.scalar_one_or_none():
            std_admin = User(
                email="admin@nammaooru.ai",
                phone="9840000001",
                password_hash=get_password_hash("Admin@123"),
                full_name="Municipal Commissioner IAS",
                role="admin",
                preferred_language="ta",
                is_active=True,
                is_verified=True,
            )
            db.add(std_admin)

        # 6B. Citizen: citizen@nammaooru.ai / Citizen@123
        std_citizen_res = await db.execute(select(User).where(User.email == "citizen@nammaooru.ai"))
        std_citizen_user = std_citizen_res.scalar_one_or_none()
        if not std_citizen_user:
            std_citizen_user = User(
                email="citizen@nammaooru.ai",
                phone="9840000002",
                password_hash=get_password_hash("Citizen@123"),
                full_name="Namma Ooru Citizen",
                role="citizen",
                preferred_language="ta",
                is_active=True,
                is_verified=True,
            )
            db.add(std_citizen_user)
            await db.flush()

            w104 = ward_lookup.get("Ward 104")
            std_profile = CitizenProfile(
                user_id=std_citizen_user.id,
                city="Chennai",
                municipality_name="Greater Chennai Corporation",
                zone="Zone 8 (Anna Nagar)",
                ward_id=w104.id if w104 else None,
                ward_number="Ward 104",
                address="10, 4th Avenue, Anna Nagar, Chennai",
                latitude=13.0850,
                longitude=80.2101,
            )
            db.add(std_profile)

        # 6C. Field Officer: officer@nammaooru.ai / Officer@123
        std_officer_res = await db.execute(select(User).where(User.email == "officer@nammaooru.ai"))
        if not std_officer_res.scalar_one_or_none():
            std_officer = User(
                email="officer@nammaooru.ai",
                phone="9840000003",
                password_hash=get_password_hash("Officer@123"),
                full_name="Field Officer K. Sivakumar",
                role="field_officer",
                preferred_language="ta",
                is_active=True,
                is_verified=True,
            )
            db.add(std_officer)
            await db.flush()

            water_dept_res = await db.execute(select(Department).where(Department.code == "WSD"))
            water_dept = water_dept_res.scalar_one_or_none()
            if water_dept:
                std_officer_profile = FieldOfficer(
                    user_id=std_officer.id,
                    department_id=water_dept.id,
                    employee_id="GCC-WSD-202",
                    designation="Ward Assistant Engineer",
                    assigned_zone="Zone 8 (Anna Nagar)",
                    is_available=True,
                )
                db.add(std_officer_profile)

        # 7. Seed Geo-Complaints across Chennai for OpenStreetMap
        sample_complaints = [
            {
                "number": "NO-2026-MAP001",
                "title": "Major Drinking Water Pipeline Burst",
                "description": "High pressure potable drinking water leaking rapidly on 2nd Avenue, flooding the road.",
                "description_ta": "2வது அவென்யூவில் குடிநீர் குழாய் உடைந்து சாலை முழுவதும் தண்ணீர் வீணாகிறது.",
                "category": "water_supply",
                "priority": "critical",
                "status": "in_progress",
                "latitude": 13.0850,
                "longitude": 80.2101,
                "address": "2nd Avenue, Anna Nagar, Chennai",
                "ward": "Ward 102",
                "zone": "Zone 8 (Anna Nagar)",
            },
            {
                "number": "NO-2026-MAP002",
                "title": "Overflowing Public Garbage Dump",
                "description": "Commercial market waste uncollected for 3 days attracting stray animals and pests.",
                "description_ta": "3 நாட்களாக குப்பை அகற்றப்படாமல் குவிந்துள்ளது. துர்நாற்றம் வீசுகிறது.",
                "category": "solid_waste",
                "priority": "high",
                "status": "submitted",
                "latitude": 13.0400,
                "longitude": 80.2300,
                "address": "Usman Road Market, T. Nagar, Chennai",
                "ward": "Ward 114",
                "zone": "Zone 10 (Kodambakkam / T. Nagar)",
            },
            {
                "number": "NO-2026-MAP003",
                "title": "Severe Deep Road Cave-in & Pothole",
                "description": "Dangerous 2-foot pothole on main bus route causing severe traffic hazard and accidents.",
                "description_ta": "பேருந்து செல்லும் பிரதான சாலையில் பெரிய பள்ளம் ஏற்பட்டுள்ளது.",
                "category": "roads_footpaths",
                "priority": "critical",
                "status": "assigned",
                "latitude": 13.0300,
                "longitude": 80.2150,
                "address": "100 Feet Road, Vadapalani, Chennai",
                "ward": "Ward 128",
                "zone": "Zone 10 (Kodambakkam / T. Nagar)",
            },
            {
                "number": "NO-2026-MAP004",
                "title": "Multiple Streetlights Non-Functional",
                "description": "Entire stretch of residential street dark for one week posing safety risk for women and pedestrians.",
                "description_ta": "ஒரு வாரமாக தெருவிளக்குகள் எரியவில்லை. இரவு நேரத்தில் இருட்டாக உள்ளது.",
                "category": "street_lighting",
                "priority": "medium",
                "status": "resolved",
                "latitude": 13.0200,
                "longitude": 80.2200,
                "address": "Gandhi Road, Velachery, Chennai",
                "ward": "Ward 177",
                "zone": "Zone 13 (Adyar / Velachery)",
            },
            {
                "number": "NO-2026-MAP005",
                "title": "Underground Sewer Overflow into Street",
                "description": "Blocked sewer manhole overflowing with contaminated wastewater on public walkway.",
                "description_ta": "பாதாள சாக்கடை அடைப்பு ஏற்பட்டு கழிவுநீர் சாலையில் பெருக்கெடுத்து ஓடுகிறது.",
                "category": "drainage_sewage",
                "priority": "high",
                "status": "under_review",
                "latitude": 13.0700,
                "longitude": 80.2500,
                "address": "Luz Church Road, Mylapore, Chennai",
                "ward": "Ward 123",
                "zone": "Zone 9 (Teynampet)",
            },
        ]

        # Get a citizen user for complaint authoring
        citizen_res = await db.execute(select(User).where(User.role == "citizen"))
        author = citizen_res.scalars().first()
        author_id = author.id if author else admin_user.id

        for sc in sample_complaints:
            existing_c = await db.execute(select(Complaint).where(Complaint.complaint_number == sc["number"]))
            if not existing_c.scalar_one_or_none():
                complaint = Complaint(
                    complaint_number=sc["number"],
                    citizen_id=author_id,
                    title=sc["title"],
                    description=sc["description"],
                    description_ta=sc["description_ta"],
                    category=sc["category"],
                    priority=sc["priority"],
                    status=sc["status"],
                    latitude=sc["latitude"],
                    longitude=sc["longitude"],
                    address=sc["address"],
                    ward_number=sc["ward"],
                    zone=sc["zone"],
                    language_detected="ta",
                )
                db.add(complaint)
                await db.flush()

                history = ComplaintStatusHistory(
                    complaint_id=complaint.id,
                    previous_status=None,
                    new_status=sc["status"],
                    changed_by=author_id,
                    notes=f"Initial seed ticket in {sc['category']}",
                )
                db.add(history)

        await db.commit()
        print("✅ Database tables created & seed data successfully inserted!")

if __name__ == "__main__":
    asyncio.run(seed_data())
