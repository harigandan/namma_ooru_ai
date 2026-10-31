import pytest
import pytest_asyncio
import random
from httpx import AsyncClient, ASGITransport
from app.main import app

@pytest.mark.asyncio
async def test_root_health():
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as client:
        response = await client.get("/")
        assert response.status_code == 200
        data = response.json()
        assert data["status"] == "online"
        assert "Tamil Nadu" in data["jurisdiction"]

@pytest.mark.asyncio
async def test_auth_login_seeded_admin():
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as client:
        response = await client.post(
            "/api/v1/auth/login",
            json={
                "email_or_phone": "admin@nammaooru.tn.gov.in",
                "password": "Admin@NammaOoru2026"
            }
        )
        assert response.status_code == 200
        data = response.json()
        assert "access_token" in data
        assert data["role"] == "admin"

@pytest.mark.asyncio
async def test_default_dev_accounts_login_and_roles():
    """Verify all 3 standard test accounts authenticate and return correct backend roles"""
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as client:
        # 1. Citizen
        cit = await client.post(
            "/api/v1/auth/login",
            json={"email_or_phone": "citizen@nammaooru.ai", "password": "Citizen@123"}
        )
        assert cit.status_code == 200
        assert cit.json()["role"] == "citizen"

        # 2. Municipal Admin
        adm = await client.post(
            "/api/v1/auth/login",
            json={"email_or_phone": "admin@nammaooru.ai", "password": "Admin@123"}
        )
        assert adm.status_code == 200
        assert adm.json()["role"] == "admin"

        # 3. Field Officer
        off = await client.post(
            "/api/v1/auth/login",
            json={"email_or_phone": "officer@nammaooru.ai", "password": "Officer@123"}
        )
        assert off.status_code == 200
        assert off.json()["role"] == "field_officer"

@pytest.mark.asyncio
async def test_auth_invalid_credentials_rejected():
    """Verify incorrect password and non-existent users are rejected with 401"""
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as client:
        # Wrong password
        bad_pw = await client.post(
            "/api/v1/auth/login",
            json={"email_or_phone": "citizen@nammaooru.ai", "password": "WrongPassword999"}
        )
        assert bad_pw.status_code == 401
        assert "Incorrect" in bad_pw.json()["detail"]

        # Unknown email
        unknown = await client.post(
            "/api/v1/auth/login",
            json={"email_or_phone": "nonexistent@nammaooru.ai", "password": "Password123"}
        )
        assert unknown.status_code == 401

@pytest.mark.asyncio
async def test_privileged_registration_authorization_enforced():
    """Verify public registration cannot escalate privileges without government code"""
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as client:
        import time
        ts = int(time.time())

        # Attempt to create admin without code -> MUST BE REJECTED 403
        bad_admin = await client.post(
            "/api/v1/auth/register",
            json={
                "email": f"hacker_admin_{ts}@test.com",
                "phone": f"9700{str(ts)[-6:]}",
                "password": "SecretPassword123",
                "full_name": "Unauthorized Admin",
                "role": "admin",
            }
        )
        assert bad_admin.status_code == 403
        assert "invitation code" in bad_admin.json()["detail"].lower()

        # Create admin WITH valid code -> SUCCEEDS
        good_admin = await client.post(
            "/api/v1/auth/register",
            json={
                "email": f"auth_admin_{ts}@tn.gov.in",
                "phone": f"9711{str(ts)[-6:]}",
                "password": "SecretPassword123",
                "full_name": "Authorized Deputy Commissioner",
                "role": "admin",
                "authorization_code": "TN-ADMIN-2026",
            }
        )
        assert good_admin.status_code == 200
        assert good_admin.json()["role"] == "admin"

@pytest.mark.asyncio
async def test_auth_login_seeded_citizen():
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as client:
        response = await client.post(
            "/api/v1/auth/login",
            json={
                "email_or_phone": "citizen@example.com",
                "password": "Citizen@12345"
            }
        )
        assert response.status_code == 200
        data = response.json()
        assert "access_token" in data
        assert data["role"] == "citizen"

@pytest.mark.asyncio
async def test_auth_login_seeded_officer():
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as client:
        response = await client.post(
            "/api/v1/auth/login",
            json={
                "email_or_phone": "officer@nammaooru.tn.gov.in",
                "password": "Officer@12345"
            }
        )
        assert response.status_code == 200
        data = response.json()
        assert "access_token" in data
        assert data["role"] == "field_officer"

@pytest.mark.asyncio
async def test_user_registration_and_token_refresh():
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as client:
        import time
        uniq = int(time.time())
        reg_res = await client.post(
            "/api/v1/auth/register",
            json={
                "email": f"resident_{uniq}@example.com",
                "phone": f"9800{str(uniq)[-6:]}",
                "password": "SecurePassword123!",
                "full_name": "Karthik Subramanian",
                "preferred_language": "ta",
                "city": "Coimbatore"
            }
        )
        assert reg_res.status_code == 200
        reg_data = reg_res.json()
        assert "access_token" in reg_data
        assert "refresh_token" in reg_data

        # Refresh token test
        ref_res = await client.post(
            "/api/v1/auth/refresh",
            json={"refresh_token": reg_data["refresh_token"]}
        )
        assert ref_res.status_code == 200
        ref_data = ref_res.json()
        assert "access_token" in ref_data

@pytest.mark.asyncio
async def test_user_profile_get_and_patch():
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as client:
        login_res = await client.post(
            "/api/v1/auth/login",
            json={"email_or_phone": "citizen@example.com", "password": "Citizen@12345"}
        )
        token = login_res.json()["access_token"]
        headers = {"Authorization": f"Bearer {token}"}

        # GET /users/me
        me_res = await client.get("/api/v1/users/me", headers=headers)
        assert me_res.status_code == 200
        assert me_res.json()["email"] == "citizen@example.com"

        # PATCH /users/me
        patch_res = await client.patch(
            "/api/v1/users/me",
            headers=headers,
            json={"full_name": "Priya Ramanathan (Verified)"}
        )
        assert patch_res.status_code == 200
        assert patch_res.json()["full_name"] == "Priya Ramanathan (Verified)"

@pytest.mark.asyncio
async def test_role_based_permission_enforcement():
    """Verify citizens are strictly forbidden from accessing admin endpoints"""
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as client:
        # Citizen login
        citizen_res = await client.post(
            "/api/v1/auth/login",
            json={"email_or_phone": "citizen@example.com", "password": "Citizen@12345"}
        )
        citizen_token = citizen_res.json()["access_token"]
        citizen_headers = {"Authorization": f"Bearer {citizen_token}"}

        # Attempt to access Admin dashboard -> MUST FAIL with 403 Forbidden
        admin_res = await client.get("/api/v1/admin/dashboard", headers=citizen_headers)
        assert admin_res.status_code == 403
        assert "Access forbidden" in admin_res.json()["detail"]

@pytest.mark.asyncio
async def test_ai_classification_tamil_text():
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as client:
        login_res = await client.post(
            "/api/v1/auth/login",
            json={"email_or_phone": "citizen@example.com", "password": "Citizen@12345"}
        )
        token = login_res.json()["access_token"]
        headers = {"Authorization": f"Bearer {token}"}

        response = await client.post(
            "/api/v1/ai/classify",
            headers=headers,
            json={"text": "எங்கள் தெருவில் குப்பைத்தொட்டி நிரம்பி வழிகிறது, துர்நாற்றம் வீசுகிறது"}
        )
        assert response.status_code == 200
        data = response.json()
        assert data["detected_language"] == "ta"
        assert data["predicted_category"] == "garbage_collection"
        assert data["recommended_department_code"] == "SWM"
        assert data["category_confidence"] > 0.0

@pytest.mark.asyncio
async def test_ai_classification_english_water_leak():
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as client:
        login_res = await client.post(
            "/api/v1/auth/login",
            json={"email_or_phone": "citizen@example.com", "password": "Citizen@12345"}
        )
        token = login_res.json()["access_token"]
        headers = {"Authorization": f"Bearer {token}"}

        response = await client.post(
            "/api/v1/ai/classify",
            headers=headers,
            json={"text": "Drinking water pipeline has burst and is leaking heavily across the road"}
        )
        assert response.status_code == 200
        data = response.json()
        assert data["detected_language"] == "en"
        assert data["predicted_category"] == "water_supply"
        assert data["recommended_department_code"] == "WSD"
        assert data["predicted_priority"] in ["high", "critical"]

@pytest.mark.asyncio
async def test_maps_and_hotspots_endpoints():
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as client:
        # Public map points
        map_res = await client.get("/api/v1/maps/complaints")
        assert map_res.status_code == 200
        items = map_res.json()
        assert isinstance(items, list)
        assert len(items) >= 5
        # Verify coordinates structure
        first = items[0]
        assert "latitude" in first
        assert "longitude" in first
        assert "category" in first
        assert "status" in first

        # Category filter test
        water_res = await client.get("/api/v1/maps/complaints?category=water_supply")
        assert water_res.status_code == 200
        water_items = water_res.json()
        assert all(w["category"] == "water_supply" for w in water_items)

        # Hotspots
        hotspots_res = await client.get("/api/v1/maps/hotspots")
        assert hotspots_res.status_code == 200
        assert isinstance(hotspots_res.json(), list)

@pytest.mark.asyncio
async def test_public_announcements():
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as client:
        # Public announcements
        ann_res = await client.get("/api/v1/announcements")
        assert ann_res.status_code == 200
        assert isinstance(ann_res.json(), list)

@pytest.mark.asyncio
async def test_complete_citizen_to_administrator_lifecycle():
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as client:
        # STEP 1: Citizen logs in
        citizen_login = await client.post(
            "/api/v1/auth/login",
            json={"email_or_phone": "citizen@example.com", "password": "Citizen@12345"}
        )
        assert citizen_login.status_code == 200
        citizen_token = citizen_login.json()["access_token"]
        citizen_headers = {"Authorization": f"Bearer {citizen_token}"}

        # STEP 2: Citizen AI classifies issue
        ai_res = await client.post(
            "/api/v1/ai/classify",
            headers=citizen_headers,
            json={"text": "Road has deep dangerous crater near school, causes accidents. சாலை பள்ளம் உள்ளது"}
        )
        assert ai_res.status_code == 200
        classified = ai_res.json()
        assert classified["predicted_category"] == "road_damage"

        # STEP 3: Citizen creates complaint
        create_res = await client.post(
            "/api/v1/complaints",
            headers=citizen_headers,
            json={
                "title": "Severe road crater near School Zone",
                "description": "Road has deep dangerous crater near school, causes accidents.",
                "category": classified["predicted_category"],
                "priority": classified["predicted_priority"],
                "latitude": 13.0827,
                "longitude": 80.2707,
                "address": "4th Cross Road, Chennai",
                "ward_number": "Ward 102",
                "zone": "Zone 5"
            }
        )
        assert create_res.status_code == 201
        complaint = create_res.json()
        complaint_id = complaint["id"]
        assert complaint["status"] == "submitted"

        # STEP 4: Administrator logs in
        admin_login = await client.post(
            "/api/v1/auth/login",
            json={"email_or_phone": "admin@nammaooru.tn.gov.in", "password": "Admin@NammaOoru2026"}
        )
        assert admin_login.status_code == 200
        admin_token = admin_login.json()["access_token"]
        admin_headers = {"Authorization": f"Bearer {admin_token}"}

        # STEP 5: Administrator views complaint and assigns to department
        depts_res = await client.get("/api/v1/admin/departments", headers=admin_headers)
        assert depts_res.status_code == 200
        depts = depts_res.json()
        eng_dept = next(d for d in depts if d["code"] == "ENG")

        assign_res = await client.patch(
            f"/api/v1/admin/complaints/{complaint_id}/assign?department_id={eng_dept['id']}&officer_id=GCC-ENG-108",
            headers=admin_headers,
        )
        assert assign_res.status_code == 200
        assert assign_res.json()["status"] == "assigned"

        # STEP 6: Field Officer logs in
        officer_login = await client.post(
            "/api/v1/auth/login",
            json={"email_or_phone": "officer@nammaooru.tn.gov.in", "password": "Officer@12345"}
        )
        assert officer_login.status_code == 200
        officer_token = officer_login.json()["access_token"]
        officer_headers = {"Authorization": f"Bearer {officer_token}"}

        # STEP 7: Field Officer updates status to in_progress
        in_prog_res = await client.patch(
            f"/api/v1/complaints/{complaint_id}",
            headers=officer_headers,
            json={
                "status": "in_progress",
                "resolution_notes": "Field crew deployed with asphalt roller."
            }
        )
        assert in_prog_res.status_code == 200
        assert in_prog_res.json()["status"] == "in_progress"

        # STEP 8: Field Officer completes work and marks resolved
        resolve_res = await client.patch(
            f"/api/v1/complaints/{complaint_id}",
            headers=officer_headers,
            json={
                "status": "resolved",
                "resolution_notes": "Asphalt patching completed and road leveling restored."
            }
        )
        assert resolve_res.status_code == 200
        assert resolve_res.json()["status"] == "resolved"

        # STEP 9: Citizen views updated history timeline
        history_res = await client.get(
            f"/api/v1/complaints/{complaint_id}/history",
            headers=citizen_headers,
        )
        assert history_res.status_code == 200
        history = history_res.json()
        assert len(history) >= 3 # submitted, in_progress, resolved

        # STEP 10: Citizen submits satisfaction feedback
        feedback_res = await client.post(
            f"/api/v1/complaints/{complaint_id}/feedback?rating=5&feedback_text=Excellent+work+by+GCC",
            headers=citizen_headers,
        )
        assert feedback_res.status_code == 200
        assert feedback_res.json()["rating"] == 5

@pytest.mark.asyncio
async def test_ward_hierarchy_and_coordinate_resolution():
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as client:
        # Test Municipalities
        muni_res = await client.get("/api/v1/wards/municipalities")
        assert muni_res.status_code == 200
        munis = muni_res.json()
        assert len(munis) >= 1
        gcc = next(m for m in munis if m["code"] == "GCC")
        assert "Chennai" in gcc["name"]

        # Test Zones in GCC
        zones_res = await client.get(f"/api/v1/wards/zones?municipality_id={gcc['id']}")
        assert zones_res.status_code == 200
        zones = zones_res.json()
        assert len(zones) >= 4
        z08 = next(z for z in zones if z["code"] == "Z08")

        # Test Wards in Zone 8
        wards_res = await client.get(f"/api/v1/wards?zone_id={z08['id']}")
        assert wards_res.status_code == 200
        wards = wards_res.json()
        assert len(wards) == 5
        assert any(w["ward_number"] == "Ward 102" for w in wards)

        # Test Coordinate Resolution to nearest ward
        # Coordinates near Anna Nagar West: 13.0850, 80.2101
        res_ward = await client.get("/api/v1/wards/resolve?latitude=13.0850&longitude=80.2101")
        assert res_ward.status_code == 200
        resolved = res_ward.json()
        assert resolved["ward_number"] == "Ward 102"
        assert resolved["distance_km"] < 1.0

@pytest.mark.asyncio
async def test_citizen_registration_with_ward_and_validation():
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as client:
        # Get a valid ward id
        wards_res = await client.get("/api/v1/wards")
        w102 = next(w for w in wards_res.json() if w["ward_number"] == "Ward 102")

        rand_id = random.randint(100000, 999999)
        reg_payload = {
            "email": f"ward_citizen_{rand_id}@example.com",
            "phone": f"9800{rand_id}",
            "password": "SecurePassword123",
            "full_name": "Ward Registered Citizen",
            "city": "Chennai",
            "municipality": "Greater Chennai Corporation",
            "zone": "Zone 8 (Anna Nagar)",
            "ward_id": w102["id"],
            "ward_number": "Ward 102",
            "preferred_language": "ta"
        }
        res = await client.post("/api/v1/auth/register", json=reg_payload)
        assert res.status_code == 200
        data = res.json()
        assert data["ward_number"] == "Ward 102"
        assert data["ward_id"] == w102["id"]

        # Check /me profile returns registered ward
        token = data["access_token"]
        me_res = await client.get("/api/v1/auth/me", headers={"Authorization": f"Bearer {token}"})
        assert me_res.status_code == 200
        profile = me_res.json()
        assert profile["ward_number"] == "Ward 102"
        assert profile["ward_id"] == w102["id"]

@pytest.mark.asyncio
async def test_citizen_registration_with_invalid_ward_rejected():
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as client:
        rand_id = random.randint(100000, 999999)
        invalid_payload = {
            "email": f"invalid_ward_{rand_id}@example.com",
            "phone": f"9700{rand_id}",
            "password": "SecurePassword123",
            "full_name": "Fake Ward Citizen",
            "ward_id": "00000000-0000-0000-0000-000000000000", # non-existent
        }
        res = await client.post("/api/v1/auth/register", json=invalid_payload)
        assert res.status_code == 400
        assert "Invalid Ward selection" in res.json()["detail"]

@pytest.mark.asyncio
async def test_citizen_ward_update_request():
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as client:
        # Login standard citizen
        login_res = await client.post("/api/v1/auth/login", json={"email_or_phone": "citizen@nammaooru.ai", "password": "Citizen@123"})
        token = login_res.json()["access_token"]
        headers = {"Authorization": f"Bearer {token}"}

        # Get ward 177 (Velachery)
        wards_res = await client.get("/api/v1/wards")
        w177 = next(w for w in wards_res.json() if w["ward_number"] == "Ward 177")

        # Citizen updates their registered ward
        patch_res = await client.patch(
            "/api/v1/auth/ward",
            headers=headers,
            json={"ward_id": w177["id"], "reason": "Relocated to Velachery"}
        )
        assert patch_res.status_code == 200
        updated = patch_res.json()
        assert updated["ward_number"] == "Ward 177"
        assert updated["ward_id"] == w177["id"]

@pytest.mark.asyncio
async def test_complaint_submission_with_gps_photo_and_discrepancy():
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as client:
        login_res = await client.post("/api/v1/auth/login", json={"email_or_phone": "citizen@nammaooru.ai", "password": "Citizen@123"})
        token = login_res.json()["access_token"]
        headers = {"Authorization": f"Bearer {token}"}

        # Coordinates for Marina Beach / Royapuram (Zone 5, Ward 53)
        # But citizen's registered ward was Ward 177 or Ward 104 -> should detect discrepancy!
        fake_photo_b64 = "data:image/jpeg;base64,/9j/4AAQSkZJRgABAQEASABIAAD/2wBDAP//////////////////////////////////////////////////////////////////////////////////////wgALCAABAAEBAREA/8QAFBABAAAAAAAAAAAAAAAAAAAAAP/aAAgBAQABPxA="

        create_res = await client.post(
            "/api/v1/complaints",
            headers=headers,
            json={
                "title": "Broken pipe at Harbour beach",
                "description": "Saltwater corrosion broke pipe on beach road.",
                "latitude": 13.0850,
                "longitude": 80.2910, # Ward 53
                "gps_accuracy": 4.5,
                "address": "Harbour Port Road, Chennai",
                "ward_number": "Ward 104", # Discrepant from GPS location!
                "photo_base64": fake_photo_b64,
                "photo_filename": "leak_camera.jpg"
            }
        )
        assert create_res.status_code == 201
        comp = create_res.json()
        assert comp["gps_accuracy"] == 4.5
        assert comp["resolved_ward"] == "Ward 53"
        assert comp["ward_discrepancy"] is True
        assert len(comp["attachments"]) == 1
        att = comp["attachments"][0]
        assert att["gps_accuracy"] == 4.5
        assert "/uploads/complaints/" in att["file_url"]

