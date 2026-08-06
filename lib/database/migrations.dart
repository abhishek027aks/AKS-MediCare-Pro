import 'package:sqflite/sqflite.dart';

class DatabaseMigrations {
  DatabaseMigrations._();

  /// Create all database tables
  static Future<void> createTables(Database db) async {
    // ==========================================================
    // Users Table
    // ==========================================================

    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        full_name TEXT NOT NULL,
        username TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        role TEXT NOT NULL,
        department TEXT,
        branch_id INTEGER,
        branch_name TEXT,
        is_active INTEGER NOT NULL DEFAULT 1,
        must_change_password INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL
      )
    ''');

    // ==========================================================
    // Patients Table
    // ==========================================================

    await db.execute('''
      CREATE TABLE patients(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        uhid TEXT NOT NULL UNIQUE,
        full_name TEXT NOT NULL,
        gender TEXT NOT NULL,
        date_of_birth TEXT NOT NULL,
        blood_group TEXT,
        marital_status TEXT,
        mobile TEXT NOT NULL,
        alternate_mobile TEXT,
        email TEXT,
        address TEXT,
        city TEXT,
        state TEXT,
        pincode TEXT,
        occupation TEXT,
        emergency_contact_name TEXT,
        emergency_contact_number TEXT,
        referred_by TEXT,
        notes TEXT,
        photo_path TEXT,
        branch_id INTEGER,
        branch_name TEXT,
        is_active INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_patients_uhid ON patients(uhid)
    ''');

    await db.execute('''
      CREATE INDEX idx_patients_mobile ON patients(mobile)
    ''');

    // ==========================================================
    // OPD Visits Table
    // ==========================================================

    await db.execute('''
      CREATE TABLE opd_visits(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        visit_no TEXT NOT NULL UNIQUE,
        patient_id INTEGER NOT NULL,
        patient_name TEXT NOT NULL,
        patient_uhid TEXT NOT NULL,
        doctor_id INTEGER,
        doctor_name TEXT NOT NULL,
        visit_date TEXT NOT NULL,
        visit_type TEXT NOT NULL,
        chief_complaint TEXT,
        diagnosis TEXT,
        prescription TEXT,
        consultation_fee REAL NOT NULL DEFAULT 0,
        follow_up_date TEXT,
        status TEXT NOT NULL,
        notes TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (patient_id) REFERENCES patients (id),
        FOREIGN KEY (doctor_id) REFERENCES users (id)
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_opd_visits_patient ON opd_visits(patient_id)
    ''');

    // ==========================================================
    // IPD Admissions Table
    // ==========================================================

    await db.execute('''
      CREATE TABLE ipd_admissions(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        admission_no TEXT NOT NULL UNIQUE,
        patient_id INTEGER NOT NULL,
        patient_name TEXT NOT NULL,
        patient_uhid TEXT NOT NULL,
        doctor_id INTEGER,
        doctor_name TEXT NOT NULL,
        ward TEXT NOT NULL,
        bed_number TEXT NOT NULL,
        admission_type TEXT NOT NULL,
        admission_date TEXT NOT NULL,
        diagnosis TEXT,
        room_charges_per_day REAL NOT NULL DEFAULT 0,
        status TEXT NOT NULL,
        discharge_date TEXT,
        discharge_summary TEXT,
        notes TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (patient_id) REFERENCES patients (id),
        FOREIGN KEY (doctor_id) REFERENCES users (id)
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_ipd_admissions_patient ON ipd_admissions(patient_id)
    ''');

    // ==========================================================
    // Bills Table
    // ==========================================================

    await db.execute('''
      CREATE TABLE bills(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        invoice_no TEXT NOT NULL UNIQUE,
        patient_id INTEGER NOT NULL,
        patient_name TEXT NOT NULL,
        patient_uhid TEXT NOT NULL,
        bill_type TEXT NOT NULL,
        reference_no TEXT,
        bill_date TEXT NOT NULL,
        items TEXT NOT NULL,
        subtotal REAL NOT NULL DEFAULT 0,
        discount REAL NOT NULL DEFAULT 0,
        tax REAL NOT NULL DEFAULT 0,
        total_amount REAL NOT NULL DEFAULT 0,
        paid_amount REAL NOT NULL DEFAULT 0,
        balance_amount REAL NOT NULL DEFAULT 0,
        payment_mode TEXT NOT NULL,
        payment_status TEXT NOT NULL,
        notes TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (patient_id) REFERENCES patients (id)
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_bills_patient ON bills(patient_id)
    ''');

    // ==========================================================
    // Medicines Table (Pharmacy Inventory)
    // ==========================================================

    await db.execute('''
      CREATE TABLE medicines(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        generic_name TEXT,
        category TEXT NOT NULL,
        manufacturer TEXT,
        unit TEXT NOT NULL,
        stock_quantity INTEGER NOT NULL DEFAULT 0,
        reorder_level INTEGER NOT NULL DEFAULT 0,
        unit_price REAL NOT NULL DEFAULT 0,
        batch_number TEXT,
        expiry_date TEXT,
        is_active INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_medicines_name ON medicines(name)
    ''');

    // ==========================================================
    // Lab Tests Table
    // ==========================================================

    await db.execute('''
      CREATE TABLE lab_tests(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        test_no TEXT NOT NULL UNIQUE,
        patient_id INTEGER NOT NULL,
        patient_name TEXT NOT NULL,
        patient_uhid TEXT NOT NULL,
        doctor_id INTEGER,
        doctor_name TEXT NOT NULL,
        test_name TEXT NOT NULL,
        test_category TEXT NOT NULL,
        sample_type TEXT NOT NULL,
        order_date TEXT NOT NULL,
        status TEXT NOT NULL,
        result_value TEXT,
        normal_range TEXT,
        result_unit TEXT,
        result_date TEXT,
        test_fee REAL NOT NULL DEFAULT 0,
        notes TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (patient_id) REFERENCES patients (id),
        FOREIGN KEY (doctor_id) REFERENCES users (id)
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_lab_tests_patient ON lab_tests(patient_id)
    ''');

    // ==========================================================
    // Staff Profiles Table (Doctor / Nursing clinical profiles)
    // ==========================================================

    await db.execute('''
      CREATE TABLE staff_profiles(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL UNIQUE,
        staff_name TEXT NOT NULL,
        role TEXT NOT NULL,
        specialization TEXT NOT NULL,
        department TEXT NOT NULL,
        qualification TEXT,
        license_number TEXT,
        experience_years INTEGER,
        shift_timing TEXT NOT NULL,
        consultation_fee REAL NOT NULL DEFAULT 0,
        is_available INTEGER NOT NULL DEFAULT 1,
        notes TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

    // ==========================================================
    // Inventory Items Table (General / non-pharmacy assets)
    // ==========================================================

    await db.execute('''
      CREATE TABLE inventory_items(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        item_name TEXT NOT NULL,
        category TEXT NOT NULL,
        department TEXT NOT NULL,
        quantity INTEGER NOT NULL DEFAULT 0,
        unit TEXT NOT NULL,
        purchase_date TEXT,
        purchase_price REAL,
        supplier TEXT,
        condition_status TEXT NOT NULL,
        warranty_expiry TEXT,
        serial_number TEXT,
        notes TEXT,
        is_active INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_inventory_items_name ON inventory_items(item_name)
    ''');

    // ==========================================================
    // Attendance Table (HR / Staff Management)
    // ==========================================================

    await db.execute('''
      CREATE TABLE attendance(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        staff_name TEXT NOT NULL,
        role TEXT NOT NULL,
        date TEXT NOT NULL,
        status TEXT NOT NULL,
        check_in_time TEXT,
        check_out_time TEXT,
        notes TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_attendance_user ON attendance(user_id)
    ''');

    // ==========================================================
    // Audit Logs Table
    // ==========================================================

    await db.execute('''
      CREATE TABLE audit_logs(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        user_name TEXT NOT NULL,
        role TEXT,
        action TEXT NOT NULL,
        module TEXT NOT NULL,
        description TEXT NOT NULL,
        timestamp TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_audit_logs_timestamp ON audit_logs(timestamp)
    ''');

    // ==========================================================
    // Appointments Table
    // ==========================================================

    await db.execute('''
      CREATE TABLE appointments(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        appointment_no TEXT NOT NULL UNIQUE,
        patient_id INTEGER NOT NULL,
        patient_name TEXT NOT NULL,
        patient_uhid TEXT NOT NULL,
        doctor_id INTEGER,
        doctor_name TEXT NOT NULL,
        appointment_date TEXT NOT NULL,
        appointment_time TEXT NOT NULL,
        reason_for_visit TEXT,
        status TEXT NOT NULL,
        notes TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (patient_id) REFERENCES patients (id),
        FOREIGN KEY (doctor_id) REFERENCES users (id)
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_appointments_patient ON appointments(patient_id)
    ''');

    await db.execute('''
      CREATE INDEX idx_appointments_date ON appointments(appointment_date)
    ''');

    // ==========================================================
    // Role Permissions Table
    // ==========================================================

    await db.execute('''
      CREATE TABLE role_permissions(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        role TEXT NOT NULL,
        module TEXT NOT NULL,
        can_view INTEGER NOT NULL DEFAULT 0,
        can_add INTEGER NOT NULL DEFAULT 0,
        can_edit INTEGER NOT NULL DEFAULT 0,
        can_delete INTEGER NOT NULL DEFAULT 0,
        can_approve INTEGER NOT NULL DEFAULT 0,
        UNIQUE(role, module)
      )
    ''');

    // ==========================================================
    // Delete Requests Table
    // ==========================================================

    await db.execute('''
      CREATE TABLE delete_requests(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        module TEXT NOT NULL,
        record_id INTEGER NOT NULL,
        record_label TEXT NOT NULL,
        reason TEXT NOT NULL,
        status TEXT NOT NULL,
        requested_by_user_id INTEGER NOT NULL,
        requested_by_name TEXT NOT NULL,
        reviewed_by_user_id INTEGER,
        reviewed_by_name TEXT,
        reviewed_at TEXT,
        requested_at TEXT NOT NULL,
        FOREIGN KEY (requested_by_user_id) REFERENCES users (id)
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_delete_requests_status ON delete_requests(status)
    ''');

    // ==========================================================
    // Login History Table
    // ==========================================================

    await db.execute('''
      CREATE TABLE login_history(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username_attempted TEXT NOT NULL,
        user_id INTEGER,
        user_name TEXT,
        role TEXT,
        device TEXT NOT NULL,
        status TEXT NOT NULL,
        timestamp TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_login_history_timestamp ON login_history(timestamp)
    ''');

    // ==========================================================
    // Patient Documents Table
    // ==========================================================

    await db.execute('''
      CREATE TABLE patient_documents(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        patient_id INTEGER NOT NULL,
        file_path TEXT NOT NULL,
        document_name TEXT NOT NULL,
        uploaded_at TEXT NOT NULL,
        FOREIGN KEY (patient_id) REFERENCES patients (id)
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_patient_documents_patient ON patient_documents(patient_id)
    ''');

    // ==========================================================
    // Branches Table
    // ==========================================================

    await db.execute('''
      CREATE TABLE branches(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        address TEXT,
        phone TEXT,
        is_active INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL
      )
    ''');
  }

  /// Future database upgrades
  static Future<void> upgradeDatabase(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    // Version 2
    if (oldVersion < 2) {
      // Future migration
    }

    // Version 3
    if (oldVersion < 3) {
      // Future migration
    }
  }
}
