import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../../core/models/activity_model.dart';
import '../../core/models/school_model.dart';
import '../../core/models/city_model.dart';
import 'db_tables.dart';

class DatabaseService {
  Sqflite sqflite = Sqflite();

  static const String dbName = "localDB";
  static const int dbVersion = 1;
  static Database? _database;

  static Future<Database> init() async {
    if (_database != null) {
      if (kDebugMode) {
        print("Database is not null$_database");
      }
      return _database!;
    } else {
      if (kDebugMode) {
        print("Database is  null, Obtaining Database");
      }
      _database = await _initDatabase();
      if (kDebugMode) {
        print("Database is created :$_database");
      }
      return _database!;
    }
  }

  static Future<Database> _initDatabase() async {
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, dbName);
    return await openDatabase(path,
        version: dbVersion, onCreate: _onCreate, onUpgrade: _onUpgrade);
  }

  static Future _onCreate(Database db, int version) async {
    await db.execute(DbTables.testTableCreateQuery);
    await db.execute(DbTables.offlineActivitiesCreateQuery);
    await db.execute(DbTables.schoolsTableCreateQuery);
    await db.execute(DbTables.cityTableCreateQuery);
  }

  static Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, dbName);
    await deleteDatabase(path);
  }

  Future<bool> storeListData<T>(List<T> dataList, String tableName) async {
    try {
      final db = await DatabaseService.init();
      db.transaction((txn) async {
        Batch batch = txn.batch();
        for (var element in dataList) {
          final row = (element as dynamic).toJsonDB();
          batch.insert(
            tableName,
            row,
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
        await batch.commit(noResult: true, continueOnError: true);
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> insertActivity(ActivityModel activity) async {
    final db = await DatabaseService.init();
    var res = await db.insert(
      DbTables.offlineActivities,
      activity.toJsonDB(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    if(res !=0) {
      return true;
    }
    return false;
  }

  static Future<int> deleteActivity(int activityId) async {
    final db = await DatabaseService.init();
    return db.delete(DbTables.offlineActivities,
        where: "dbID = ?", whereArgs: [activityId]);
  }

  static Future<int> updateActivity(ActivityModel activity) async {
    final db = await DatabaseService.init();
    return db.update(
      DbTables.offlineActivities,
      activity.toJsonDB(),
      where: "dbID = ?",
      whereArgs: [activity.dbID],
    );
  }

  static Future<ActivityModel?> fetchActivity(int activityId) async {
    final db = await DatabaseService.init();
    final maps = await db.query(DbTables.offlineActivities,
        where: "dbID = ?", whereArgs: [activityId]);
    if (maps.isNotEmpty) {
      return ActivityModel.fromJsonDB(maps.first);
    }
    return null;
  }

  static Future<List<ActivityModel>> getTodayActivities() async {
    final db = await DatabaseService.init();
    final date = DateFormat("yyyy-MM-dd").format(DateTime.now());
    final result = await db.rawQuery(
        'SELECT * FROM activityTable WHERE createdOn LIKE "$date%" OR modifiedOn LIKE "$date%"');
    return result.isNotEmpty
        ? result.map((activity) => ActivityModel.fromJsonDB(activity)).toList()
        : [];
  }

  static Future<List<ActivityModel>> getActivitiesByDate(
      DateTime dateTime) async {
    final db = await DatabaseService.init();
    final date = DateFormat("yyyy-MM-dd").format(dateTime);
    final result = await db.rawQuery(
        'SELECT * FROM activityTable WHERE createdOn LIKE "$date%" OR modifiedOn LIKE "$date%"');
    return result.isNotEmpty
        ? result.map((activity) => ActivityModel.fromJsonDB(activity)).toList()
        : [];
  }

  Future<List<ActivityModel>> getActivitiesBySchoolId(int schoolId) async {
    final db = await DatabaseService.init();
    final List<Map<String, dynamic>> maps = await db.query(
      DbTables.offlineActivities,
      where: 'schoolId = ?',
      whereArgs: [schoolId],
    );
    return List.generate(maps.length, (i) {
      return ActivityModel.fromJsonDB(maps[i]);
    });
  }

  Stream<List<ActivityModel>> streamActivitiesBySearchQuery(String query) {
    final db = DatabaseService.init();
    final String searchQuery = '%$query%';
    return db
        .then((database) => database.rawQuery(
              'SELECT * FROM activityTable WHERE schoolName LIKE ? OR cityName LIKE ? OR anchorName LIKE ? OR activityName LIKE ?',
              [searchQuery, searchQuery, searchQuery, searchQuery],
            ))
        .asStream()
        .map((list) =>
            list.map((json) => ActivityModel.fromJsonDB(json)).toList());
  }

  static Future<bool> insertSchools(List<SchoolModel> schoolsList) async {
    try {
      Database db = await DatabaseService.init();
      db.transaction((txn) async {
        Batch batch = txn.batch();
        for (var element in schoolsList) {
          final row = element.toJsonDB();
          batch.insert(
            DbTables.schoolsTable,
            row,
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
        await batch.commit(noResult: true, continueOnError: true);
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> insertActivities(
      List<ActivityModel> activitiesList) async {
    try {
      Database db = await DatabaseService.init();
      db.transaction((txn) async {
        Batch batch = txn.batch();
        for (var element in activitiesList) {
          final row = element.toJsonDB();
          batch.insert(
            DbTables.offlineActivities,
            row,
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
        await batch.commit(noResult: true, continueOnError: true);
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<List<ActivityModel>> fetchAllActivities() async {
    final db = await DatabaseService.init();
    final List<Map<String, dynamic>> maps = await db.query(
      DbTables.offlineActivities,
    );
    return List.generate(maps.length, (i) {
      return ActivityModel.fromJsonDB(maps[i]);
    });
  }

  static Future<List<SchoolModel>> fetchAllSchools() async {
    final db = await DatabaseService.init();
    final List<Map<String, dynamic>> maps = await db.query(
      DbTables.schoolsTable,
    );
    return List.generate(maps.length, (i) {
      return SchoolModel.fromJsonDB(maps[i]);
    });
  }

  Future<void> createIndices() async {
    final db = await DatabaseService.init();
    await db.execute(
        "CREATE INDEX index_activity_name ON ${DbTables.offlineActivities} (activityName);");
    await db.execute(
        "CREATE INDEX index_activity_type ON ${DbTables.offlineActivities} (activityType);");
    await db.execute(
        "CREATE INDEX index_anchor_id ON ${DbTables.offlineActivities} (anchorId);");
    await db.execute(
        "CREATE INDEX index_anchor_name ON ${DbTables.offlineActivities} (anchorName);");
    await db.execute(
        "CREATE INDEX index_assigned_by ON ${DbTables.offlineActivities} (assignedBy);");
    await db.execute(
        "CREATE INDEX index_school_id ON ${DbTables.offlineActivities} (schoolId);");
    await db.execute(
        "CREATE INDEX index_school_name ON ${DbTables.offlineActivities} (schoolName);");
    await db.execute(
        "CREATE INDEX index_school_address ON ${DbTables.offlineActivities} (schoolAddress);");
    await db.execute(
        "CREATE INDEX index_activity_status ON ${DbTables.offlineActivities} (activityStatus);");
    await db.execute(
        "CREATE INDEX index_modified_on ON ${DbTables.offlineActivities} (modifiedOn);");
    await db.execute(
        "CREATE INDEX index_created_on ON ${DbTables.offlineActivities} (createdOn);");
    await db.execute(
        "CREATE INDEX index_created_by ON ${DbTables.offlineActivities} (createdBy);");
    await db.execute(
        "CREATE INDEX index_city_id ON ${DbTables.offlineActivities} (cityId);");
    await db.execute(
        "CREATE INDEX index_city_name ON ${DbTables.offlineActivities} (cityName);");
    await db.execute(
        "CREATE INDEX index_is_executed ON ${DbTables.offlineActivities} (isExecuted);");
    await db.execute(
        "CREATE INDEX index_audio_file_path ON ${DbTables.offlineActivities} (audioFilePath);");
  }

  static Future<bool> insertCities(List<CityModel> citiesList) async {
    try {
      Database db = await DatabaseService.init();
      db.transaction((txn) async {
        Batch batch = txn.batch();
        for (var element in citiesList) {
          final row = element.toJsonDB();
          batch.insert(
            DbTables.cityTable,
            row,
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
        await batch.commit(noResult: true, continueOnError: true);
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<List<CityModel>> fetchAllCities() async {
    final db = await DatabaseService.init();
    final List<Map<String, dynamic>> maps = await db.query(
      DbTables.schoolsTable,
    );
    return List.generate(maps.length, (i) {
      return CityModel.fromJsonDB(maps[i]);
    });
  }

  static Future<bool> truncateTable(String tableName) async {
    try {
      final db = await DatabaseService.init();
      await db.execute('DELETE FROM $tableName');
      return true;
    } catch (e) {
      return false;
    }
  }
}

/*
class DatabaseHelper {
  static final _databaseName = "MyDatabase.db";

  static final _databaseVersion = 1;

  static final _table_create_customer = 'Create_Customer';

  static final _table_Schedule = 'Schedule';

  static final _table_ComplaintType = 'ComplaintType';

  static final _tableCustomerAddress = 'CustomerAddress';

  static final _tableCustomers = 'Customers';

  static final _tableCompanies = 'Companies';

  static final _tableReferenceSources = 'ReferenceSources';

  static final _tableReferenceSourceChild = 'ReferenceSourceChild';

  static final _tableBranches = 'Branches';

  static final _tableTeams = 'teams';

  static final _tableTeamMembers = 'TeamMembers';

  static final _table_Inquiry = 'Inquiry';

  static final _tableInquirySaved = 'OfflineInquiry';

  static final _tableOfflineLead = 'OfflineLead';

  static final _tableMeetingTypes = 'MeetingTypes';

  static final _tableScheduleDuration = 'ScheduleDuration';

  static final _tableLeadStatus = 'LeadStatus';

  static final _tableCities = 'City';

  static final _tableUnitOfMeasurement = 'UnitOfMeasurement';

  static final _tablePaymentDurations = 'PaymentDurations';

  ///NEW CODE

  static final _tableCompanyCustomers = 'CompanyCustomers';

  static final _tableSiteId = 'SiteId';

  static final _tableCommentId = 'CommentId';

  static final _tableAllComplaints = 'AllComplaints';

  static final _tableMyLeads = 'MyLeads';

  static final _tableGlobalLeads = 'GlobalLeads';

  static final _tableInquiryMeetings = 'InquiryMeetings';

  static final _tableMyTargets = 'MyTargets';

  static final _tableOfflineComplaintStatusUpdate =
      'OfflineComplaintsStatusUpdate';

  static final _tableOfflineTasks = 'OfflineTasks';

  static final String _tableAllProducts = "AllProducts";

  static Database? _database;

  DatabaseHelper._internal();

  static final DatabaseHelper _databaseHelper = new DatabaseHelper._internal();

  static DatabaseHelper get instance => _databaseHelper;

  // Database get database {
  //   return _database!;
  // }

  static init() async {
    if (_database != null) {
      print("ARK-Database is not null");
      print("ARK-Database is not null$_database");
      return _database!;
    } else {
      print("ARK-Database is  null");
      _database = await _initDatabase();
      print("ARK-Database is  null :$_database");
      return _database!;
    }
  }

  // this opens the database (and creates it if it doesn't exist)
  static _initDatabase() async {
    // Directory documentsDirectory = await getApplicationDocumentsDirectory();
    // String path = join(documentsDirectory.path, _databaseName);
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, _databaseName);
    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate, onUpgrade: _onUpgrade);
  }

  // SQL code to create the database table
  static Future _onCreate(Database db, int version) async {
    ///COMPLAINT TYPES
    await db.execute('''
          CREATE TABLE $_table_ComplaintType (
            dbID INTEGER PRIMARY KEY AUTOINCREMENT,
            Id INTEGER,
            Name TEXT
         )
          ''');

    ///LEAD STATUSES
    await db.execute('''
          CREATE TABLE $_tableLeadStatus (
            dbID INTEGER PRIMARY KEY AUTOINCREMENT,
            Id INTEGER ,
            OrderNo INTEGER ,
            Status TEXT
          )
          ''');

    ///TABLE UNIT OF MEASUREMENT
    await db.execute('''
          CREATE TABLE $_tableUnitOfMeasurement (
            dbID INTEGER PRIMARY KEY AUTOINCREMENT,
            Id TEXT ,
            Name TEXT
          )
          ''');

    ///TABLE PAYMENT DURATIONS
    await db.execute('''
          CREATE TABLE $_tablePaymentDurations (
            dbID INTEGER PRIMARY KEY AUTOINCREMENT,
            Id INTEGER ,
            Name TEXT
          )
          ''');

    ///TABLE CITIES
    await db.execute('''
          CREATE TABLE $_tableCities (
            dbID INTEGER PRIMARY KEY AUTOINCREMENT,
            Name TEXT
          )
          ''');

    ///TABLE SCHEDULE
    await db.execute('''
          CREATE TABLE $_table_Schedule (
            dbID INTEGER PRIMARY KEY AUTOINCREMENT,
            Id TEXT,
            title TEXT ,
            privacy TEXT ,
            date TEXT ,
            duration TEXT ,
            type TEXT ,
            description TEXT,
            status INTEGER
          )
          ''');

    ///TABLE CREATE CUSTOMER
    await db.execute('''
          CREATE TABLE $_table_create_customer (
            dbID INTEGER PRIMARY KEY AUTOINCREMENT,
            Name TEXT ,
            Mobile_no TEXT ,
            Phone_no TEXT ,
            Customer_email TEXT ,
            Customer_address TEXT
          )
          ''');

    // Add Customer Address
    await db.execute('''
          CREATE TABLE $_table_Inquiry (
            dbID INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT ,
            mobile_no TEXT ,
            phone_no TEXT ,
            customer_email TEXT ,
            customer_address TEXT ,
            opportunity_Title TEXT ,
            reference_by TEXT ,
            reference_source_id TEXT ,
            reference_child_id TEXT ,
            inquiry_details TEXT ,
            company_id TEXT ,
            branch_id TEXT ,
            team_id TEXT ,
            team_member_id TEXT,
            imagesJson TEXT,
            latitude TEXT,
            longitude TEXT
          )
          ''');

    await db.execute('''
          CREATE TABLE $_tableInquirySaved (
            dbId INTEGER PRIMARY KEY AUTOINCREMENT,
            Id INTEGER,
            CustomId TEXT,
            CompanyId INTEGER,
            BranchId INTEGER,
            TeamId INTEGER,
            TeamMemberId INTEGER,
            CustomerId INTEGER,
            CustomerAddressId INTEGER,
            OpportunityTitle TEXT,
            InquiryDetail TEXT,
            ReferenceSource TEXT,
            ReferenceSourceChild INTEGER,
            ReferenceBy TEXT,
            CustomerName TEXT,
            CustomerMobileNo TEXT,
            CustomerPhoneNo TEXT,
            CustomerEmail TEXT,
            CustomerAddress TEXT,
            CityId INTEGER,
            StatusId INTEGER,
            Remarks TEXT,
            Latitude TEXT,
            Longitude TEXT,
            OfflineExecuteTime TEXT,
            Active INTEGER,
            ModifiedOn TEXT,
            CreatedBy INTEGER,
            isInquiryCompleted TEXT,
            isExecuted TEXT
          )
          ''');

    ///TABLE INQUIRY SAVED
    await db.execute('''
          CREATE TABLE $_tableInquirySaved (
            dbId INTEGER PRIMARY KEY AUTOINCREMENT,
            Id INTEGER,
            CustomId TEXT,
            CompanyId INTEGER,
            BranchId INTEGER,
            TeamId INTEGER,
            TeamMemberId INTEGER,
            CustomerId INTEGER,
            CustomerAddressId INTEGER,
            OpportunityTitle TEXT,
            InquiryDetail TEXT,
            ReferenceSource TEXT,
            ReferenceSourceChild INTEGER,
            ReferenceBy TEXT,
            TempCustomerId INTEGER,
            TempCustomerName TEXT,
            TempCustomerMobileNo TEXT,
            TempCustomerEmail TEXT,
            TempCustomerCNICNo TEXT,
            TempCustomerCity TEXT,
            TempCustomerAddress TEXT,
            CustomerType TEXT,
            CityId TEXT,
            StatusId INTEGER,
            Remarks TEXT,
            Latitude TEXT,
            Longitude TEXT,
            OfflineExecuteTime TEXT,
            Active INTEGER,
            ModifiedOn TEXT,
            CreatedBy INTEGER,
            isExecuted TEXT,
            Files TEXT
          )
          ''');

    ///TABLE OFFLINE LEADS
    await db.execute('''
          CREATE TABLE $_tableOfflineLead (
            dbId INTEGER PRIMARY KEY AUTOINCREMENT,
            Id INTEGER UNIQUE,
            InquiryNo TEXT,
            Company TEXT,
            Team TEXT,
            BranchName TEXT,
            TeamAssignToMemberName TEXT,
            OpportunityTitle TEXT,
            InquiryDetail TEXT,
            ReferenceSource TEXT,
            ReferenceSourceChid TEXT,
            ReferenceBy TEXT,
            CustomerName TEXT,
            CustomerMobileNo TEXT,
            CustomerEmail TEXT,
            Status TEXT,
            Active INTEGER,
            ModifiedOn TEXT,
            CreatedBy INTEGER,
            isExecuted TEXT,
            localStatusId INTEGER,
            CustomerAddressId INTEGER,
            PKCustomerID INTEGER,
            CompanyId INTEGER,
            BranchId INTEGER,
            TeamId INTEGER,
            TeamMemberId INTEGER,
            SalesOfficerName TEXT,
            LastUserName TEXT,
            CustomerID INTEGER,
            CustomerCNICNo INTEGER
           )
          ''');

    ///TABLE CUSTOMERS
    await db.execute('''
          CREATE TABLE $_tableCustomers (
            dbId INTEGER PRIMARY KEY AUTOINCREMENT,
            Id INTEGER,
            CustomerID TEXT,
            Name TEXT,
            DefaultAddressID TEXT,
            ContactNo TEXT,
            CNICNo TEXT,
            Email TEXT,
            companyId INTEGER,
            company TEXT,
            branch TEXT
          )
          ''');

    ///NEW CODE FOR ADDING COMPANY WISE CUSTOMERS
    await db.execute('''
          CREATE TABLE $_tableCompanyCustomers (
            dbId INTEGER PRIMARY KEY AUTOINCREMENT,
            Id INTEGER,
            CustomerID TEXT,
            Name TEXT,
            DefaultAddressID TEXT,
            ContactNo TEXT,
            CNICNo TEXT,
            Email TEXT,
            companyId INTEGER,
            company TEXT,
            branch TEXT
          )
          ''');

    ///TABLE CUSTOMER ADDRESSES
    await db.execute('''
          CREATE TABLE $_tableCustomerAddress (
            dbId INTEGER PRIMARY KEY AUTOINCREMENT,
            Id INTEGER,
            AddressID TEXT,
            Address1 TEXT,
            fk_CustomerID INTEGER,
            ContactNumber TEXT,
            CustomerCity TEXT

          )
          ''');

    ///TABLE COMPANIES
    await db.execute('''
          CREATE TABLE $_tableCompanies (
            dbId INTEGER PRIMARY KEY AUTOINCREMENT,
            Id INTEGER,
            Name TEXT
          )
          ''');

    ///TABLE REFERENCE SOURCES
    await db.execute('''
          CREATE TABLE $_tableReferenceSources (
            dbId INTEGER PRIMARY KEY AUTOINCREMENT,
            Id INTEGER,
            Name TEXT
          )
          ''');

    ///TABLE REFERENCE SOURCE CHILD
    await db.execute('''
          CREATE TABLE $_tableReferenceSourceChild (
            dbId INTEGER PRIMARY KEY AUTOINCREMENT,
            Id INTEGER,
            Name TEXT,
            ReferenceSourceId INTEGER
          )
          ''');

    ///TABLE BRANCHES
    await db.execute('''
          CREATE TABLE $_tableBranches (
            dbId INTEGER PRIMARY KEY AUTOINCREMENT,
            Id TEXT UNIQUE,
            Name TEXT,
            CompanyId INTEGER
          )
          ''');

    ///TABLE TEAMS
    await db.execute('''
          CREATE TABLE $_tableTeams (
            dbId INTEGER PRIMARY KEY AUTOINCREMENT,
            Id TEXT UNIQUE,
            Name TEXT,
            BranchId INTEGER
          )
          ''');

    ///TABLE TEAM MEMBERS
    await db.execute('''
        CREATE TABLE $_tableTeamMembers (
            dbId INTEGER PRIMARY KEY AUTOINCREMENT,
            Id TEXT UNIQUE,
            Name TEXT,
            TeamIds TEXT
          )
      ''');

    ///TABLE MEETING TYPES
    await db.execute('''
          CREATE TABLE $_tableMeetingTypes (
            dbId INTEGER PRIMARY KEY AUTOINCREMENT,
            Id INTEGER,
            Name TEXT
          )
          ''');

    ///TABLE SCHEDULE DURATIONS
    await db.execute('''
          CREATE TABLE $_tableScheduleDuration (
            dbId INTEGER PRIMARY KEY AUTOINCREMENT,
            Id INTEGER,
            Name TEXT
          )
          ''');

    ///TABLE ALL COMPLAINTS
    await db.execute('''
          CREATE TABLE $_tableAllComplaints (
            dbId INTEGER PRIMARY KEY AUTOINCREMENT,
            Id INTEGER UNIQUE,
            CustomerId INTEGER,
            ComplaintTypeId INTEGER,
            MobileNumber TEXT,
            ComplaintTitle TEXT,
            ComplaintMessage TEXT,
            CustomerName TEXT,
            Email TEXT,
            PhoneNumber TEXT,
            CustomId TEXT,
            Priority TEXT,
            LeadId INTEGER,
            Status TEXT,
            Remarks TEXT,
            Active BIT,
            ModifiedOn TEXT,
            CreatedBy INTEGER,
            CreatedOn TEXT,
            CompanyID INTEGER,
            BranchID INTEGER,
            TeamID INTEGER,
            TeamMemberID INTEGER,
            CompanyName INTEGER,
            BranchName TEXT,
            TeamName TEXT,
            TeamMemberName TEXT
          );
    ''');

    ///NEW CODE FOR STORING DYNAMIC SITE ID's
    await db.execute('''
          CREATE TABLE $_tableSiteId (
           dbId	INTEGER UNIQUE PRIMARY KEY AUTOINCREMENT,
             siteCode	TEXT,
             siteDescription TEXT
            )
          ''');

    ///NEW CODE FOR STORING Dynamic Comment ID's
    await db.execute('''
          CREATE TABLE $_tableCommentId (
             dbId	INTEGER PRIMARY KEY AUTOINCREMENT,
             commentCode	TEXT UNIQUE,
             commentDescription	TEXT
            )
          ''');

    ///NEW CODE FOR SAVING MY LEADS
    await db.execute('''
          CREATE TABLE $_tableMyLeads (
            dbId INTEGER PRIMARY KEY AUTOINCREMENT,
            Id INTEGER UNIQUE,
            InquiryNo TEXT,
            Company TEXT,
            Team TEXT,
            BranchName TEXT,
            TeamAssignToMemberName TEXT,
            OpportunityTitle TEXT,
            InquiryDetail TEXT,
            ReferenceSource TEXT,
            ReferenceSourceChid TEXT,
            ReferenceBy TEXT,
            CustomerName TEXT,
            CustomerMobileNo TEXT,
            CustomerEmail TEXT,
            Status TEXT,
            Active BIT,
            ModifiedOn TEXT,
            CreatedBy INTEGER,
            isExecuted TEXT,
            localStatusId,
            CustomerAddressId INTEGER,
            PKCustomerID INTEGER,
            CompanyId INTEGER,
            BranchId INTEGER,
            TeamId INTEGER,
            TeamMemberId INTEGER,
            SalesOfficerName TEXT,
            LastUserName TEXT,
            CustomerID INTEGER,
            CustomerCNICNo INTEGER
          )
    ''');

    ///NEW CODE FOR OFFLINE GLOBAL LEADS
    await db.execute('''
       CREATE TABLE $_tableGlobalLeads (
            dbId INTEGER PRIMARY KEY AUTOINCREMENT,
            Id INTEGER UNIQUE,
            InquiryNo TEXT,
            Company TEXT,
            Team TEXT,
            BranchName TEXT,
            TeamAssignToMemberName TEXT,
            OpportunityTitle TEXT,
            InquiryDetail TEXT,
            ReferenceSource TEXT,
            ReferenceSourceChid TEXT,
            ReferenceBy TEXT,
            CustomerName TEXT,
            CustomerMobileNo TEXT,
            CustomerEmail TEXT,
            Status TEXT,
            Active BIT,
            ModifiedOn TEXT,
            CreatedBy INTEGER,
            isExecuted TEXT,
            localStatusId INTEGER
          )
      ''');

    ///NEW CODE FOR OFFLINE TASKS AND MEETINGS AGAINST INQUIRIES
    await db.execute('''
     CREATE TABLE $_tableInquiryMeetings (
            dbId INTEGER PRIMARY KEY AUTOINCREMENT,
            Id INTEGER UNIQUE,
            Title TEXT,
            Description TEXT,
            MeetingType TEXT,
            Remarks TEXT,
            MeetingTypeId INTEGER,
            LeadManagementId INTEGER,
            StartingTime TEXT,
            Duration TEXT,
            Privacy INTEGER,
            Active BIT,
            ModifiedOn TEXT,
            ReportMarkTime Text,
            CreatedBy INTEGER,
            Status INTEGER,
            LeadStatus INTEGER,
            ExecutedTime TEXT,
            IsExecuted BIT,
            CustomIdentityId INTEGER,
            CustomId TEXT,
            LeadStatusId INTEGER,
            CustomerId INTEGER,
            CustomerName TEXT
          )
    ''');

    ///Table For Storing Offline Tasks Executions and Updates
    await db.execute('''
     CREATE TABLE $_tableOfflineTasks (
            dbId INTEGER PRIMARY KEY AUTOINCREMENT,
            Id INTEGER,
            Title TEXT,
            Description TEXT,
            MeetingType TEXT,
            Remarks TEXT,
            MeetingTypeId INTEGER,
            LeadManagementId INTEGER,
            StartingTime TEXT,
            Duration TEXT,
            Privacy INTEGER,
            Active BIT,
            ModifiedOn TEXT,
            ReportMarkTime Text,
            CreatedBy INTEGER,
            Status INTEGER,
            LeadStatus INTEGER,
            ExecutedTime TEXT,
            IsExecuted BIT,
            CustomIdentityId INTEGER,
            CustomId TEXT,
            LeadStatusId INTEGER,
            CustomerId INTEGER,
            CustomerName TEXT
          )
    ''');

    ///Table for Storing MyTargets
    await db.execute('''
      CREATE TABLE $_tableMyTargets (
      dbId INTEGER PRIMARY KEY AUTOINCREMENT,
      id INTEGER UNIQUE,
      teamName TEXT,
      employeeId INTEGER,
      employeeName TEXT,
      fromDate TEXT,
      toDate TEXT,
      quarterId INTEGER,
      customId TEXT,
      targetDateRange TEXT,
      forcastAmount INTEGER,
      targetType TEXT,
      targetYear INTEGER,
      noOfVisits INTEGER,
      amount INTEGER,
      modifiedOn TEXT
      );
    ''');

    ///Table for Offline Complaint Status Update
    await db.execute('''
      CREATE TABLE $_tableOfflineComplaintStatusUpdate (
      dbId INTEGER PRIMARY KEY AUTOINCREMENT,
      Id INTEGER UNIQUE,
      Title TEXT,
      Status TEXT,
      Remarks TEXT,
      LeadManagementId INTEGER,
      ModifiedOn TEXT,
      CreatedBy INTEGER,
      OfflineExecutionTime TEXT
      );
      ''');

    ///Table for All Products with Company Id
    await db.execute('''
      CREATE TABLE $_tableAllProducts (
      dbId INTEGER PRIMARY KEY AUTOINCREMENT,
      id INTEGER UNIQUE,
      name TEXT,
      itemNumber TEXT,
      locncode TEXT,
      itemsInPallete TEXT,
      palleteCharges TEXT,
      currentCost FLOAT,
      standardCost FLOAT,
      uofMSCHID TEXT,
      companyId INTEGER
      );
    ''');
  }

  static Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, _databaseName);
    await deleteDatabase(path);
    // _onCreate;
  }

  /////////////////////////////////////////////////////////////////////////////////////////
  //  Create Schedule Method
  static Future<int> db_insert_Schedule(ScheduleModel _scheduleModel) async {
    Database _db = await DatabaseHelper.init();
    print("Comp:$_scheduleModel");
    final row = _scheduleModel.toJson();
    print("Row:$row");
    return await _db.insert(_table_Schedule, row,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<List<ScheduleModel>> db_getAll_Schedule() async {
    Database _db = await DatabaseHelper.init();
    return await _db
        .rawQuery('SELECT * FROM $_table_Schedule')
        .then((value) => value.map((e) => ScheduleModel.fromJson(e)).toList());
  }

  static Future<ScheduleModel?> db_getSingle_Schedule(String id) async {
    Database _db = await DatabaseHelper.init();
    ScheduleModel? _scheduleModel = await _db
        .query(_table_Schedule, where: "dbID = ?", whereArgs: [id], limit: 1)
        .then((value) {
      print("val$value");
      if (value.isNotEmpty) {
        return value.map((e) => ScheduleModel.fromJson(e)).first;
      } else {
        return null;
      }
    });
    print("Dynamic:$_scheduleModel");
    return _scheduleModel;
  }

  static Future<int> db_updateSingle_Schedule(
      String dbID, ScheduleModel scheduleModel) async {
    Database _db = await DatabaseHelper.init();
    // Map<String, dynamic> values = {"isExecuted": value};

    return await _db.update(_table_Schedule, scheduleModel.toJson(),
        where: "dbID = ?", whereArgs: [dbID]);
  }

  static Future db_deleteAll_Schedule() async {
    Database _db = await DatabaseHelper.init();
    return _db.delete(_table_Schedule);
  }

//////////////////////////////////////////////////////////////////////////////
  //  Create Complain Method

  static Future<int> dbInsertAllComplaintType(
      List<ComplaintTypeModel>? complaintTypeModel) async {
    Database _db = await DatabaseHelper.init();
    print("Ark-Start");
    // Batch batch = _db.batch();
    int index = -1;
    complaintTypeModel!.forEach((element) async {
      final row = element.toJson();
      index = await _db.insert(_table_ComplaintType, row,
          conflictAlgorithm: ConflictAlgorithm.replace);
      // batch.insert(_table_ComplaintType, row);
    });

    // await batch.commit(noResult: true);
    print("Ark-End");
    return index;
  }

  static Future<int> db_insert_CompalinType(
      ComplaintTypeModel _complaintsModel) async {
    Database _db = await DatabaseHelper.init();
    print("Comp:$_complaintsModel");
    final row = _complaintsModel.toJson();
    print("Row:$row");
    return await _db.insert(_table_ComplaintType, row,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<List<ComplaintTypeModel>> db_getAll_CompalinType() async {
    Database _db = await DatabaseHelper.init();
    return await _db.rawQuery('SELECT * FROM $_table_ComplaintType').then(
            (value) => value.map((e) => ComplaintTypeModel.fromJson(e)).toList());
  }

  static Future<ComplaintTypeModel?> db_getSingle_CompalinType(
      String id) async {
    Database _db = await DatabaseHelper.init();
    ComplaintTypeModel? _complaintsModel = await _db
        .query(_table_ComplaintType, where: "Id = ?", whereArgs: [id], limit: 1)
        .then((value) {
      print("val$value");
      if (value.isNotEmpty) {
        return value.map((e) => ComplaintTypeModel.fromJson(e)).first;
      } else {
        return null;
      }
    });
    print("Dynamic:$_complaintsModel");
    return _complaintsModel;
  }

  static Future<int> db_updateSingle_CompalinType(
      String dbID, ComplaintTypeModel complaintTypeModel) async {
    Database _db = await DatabaseHelper.init();

    return await _db.update(_table_ComplaintType, complaintTypeModel.toJson(),
        where: "dbID = ?", whereArgs: [dbID]);
  }

  static Future dbDeleteAllCompalinType() async {
    Database _db = await DatabaseHelper.init();
    return _db.delete(_table_ComplaintType);
  }

  /////////////////////////////////////////////////////////////////////////////////////////
  //  Create Inquiry Method
  // static Future<int> db_insert_Inquiry(InquiryModel _inquiryModel) async {
  //   Database _db = await DatabaseHelper.init();
  //   final row = _inquiryModel.toJson();
  //   return await _db.insert(_table_Inquiry, row);
  // }

  static Future<List<InquiryModel>> db_getAll_Inquiry() async {
    Database _db = await DatabaseHelper.init();
    return await _db
        .rawQuery('SELECT * FROM Inquiry')
        .then((value) => value.map((e) => InquiryModel.fromJson(e)).toList());

    // return [];
    // return await _db
    //     .rawQuery('SELECT * FROM Inquiry')
    //     .then((value) => value.map((e) {
    //   print("E" + e.toString());
    //   return InquiryModel.fromJson(e);
    // }).toList());
  }

  static Future<InquiryModel?> db_getSingle_Inquiry(String id) async {
    Database _db = await DatabaseHelper.init();
    InquiryModel? _inquiryModel = await _db
        .query(_table_Inquiry,
            where: "customerID = ?", whereArgs: [id], limit: 1)
        .then((value) {
      print("val" + value.toString());
      if (value.isNotEmpty) {
        return value.map((e) => InquiryModel.fromJson(e)).first;
      } else {
        return null;
      }
    });
    print("Dynamic:" + _inquiryModel.toString());
    return _inquiryModel;
  }

  static Future<int> db_updateSingle_Inquiry(
      String dbID, InquiryModel inquiryModel) async {
    Database _db = await DatabaseHelper.init();
    // Map<String, dynamic> values = {"isExecuted": value};

    return await _db.update(_table_Inquiry, inquiryModel.toJson(),
        where: "dbID = ?", whereArgs: [dbID]);
  }

  static Future db_deleteAll_Inquiry() async {
    Database _db = await DatabaseHelper.init();
    return _db.delete(_table_Inquiry);
  }

  ///Create Customer Method
  static Future<int> db_insert_Create_Customer(
      CreateCustomerModel _createCustomer) async {
    Database _db = await DatabaseHelper.init();
    final row = _createCustomer.toJson();
    return await _db.insert(_table_create_customer, row,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<List<CreateCustomerModel>> db_getAll_Create_Customers() async {
    Database _db = await DatabaseHelper.init();
    return await _db.query(_table_create_customer).then(
            (value) => value.map((e) => CreateCustomerModel.fromJson(e)).toList());
  }

  static Future<CreateCustomerModel?> db_getSingle_Create_Customer(
      String id) async {
    Database _db = await DatabaseHelper.init();
    CreateCustomerModel? _createCustomer = await _db
        .query(_table_create_customer,
        where: "customerID = ?", whereArgs: [id], limit: 1)
        .then((value) {
      print("val$value");
      if (value.isNotEmpty) {
        return value.map((e) => CreateCustomerModel.fromJson(e)).first;
      } else {
        return null;
      }
    });
    print("Dynamic:$_createCustomer");
    return _createCustomer;
  }

  // static Future<int> db_updateSingle_CreateCustomer(
  //     String id, String value) async {
  //   Database _db = await DatabaseHelper.init();
  //   Map<String, dynamic> values = {"isExecuted": value};
  //   return await _db.update(_table_create_customer, values,
  //       where: "dbId = ?", whereArgs: [id]);
  // }

  static Future db_deleteAll_Create_Customers() async {
    Database _db = await DatabaseHelper.init();
    return _db.delete(_table_create_customer);
  }

  // Create Add New Address Method
  // static Future<int> db_insert_Add_Customer_Address(
  //     Add_Customer_AddressModel _add_customer_addressModel) async {
  //   Database _db = await DatabaseHelper.init();
  //   final row = _add_customer_addressModel.toJson();
  //   return await _db.insert(_table_add_customer_address, row);
  // }

  // static Future<List<Add_Customer_AddressModel>>
  //     db_getAll_Add_Customer_Address() async {
  //   Database _db = await DatabaseHelper.init();
  //   return await _db.query(_table_add_customer_address).then((value) =>
  //       value.map((e) => Add_Customer_AddressModel.fromJson(e)).toList());
  // }

  // static Future<List<Add_Customer_AddressModel>>
  //     db_getAllQuery_Add_Customer_Address(String id) async {
  //   Database _db = await DatabaseHelper.init();
  //
  //   List<Add_Customer_AddressModel> _add_customer_addressModel = await _db
  //       .query(_table_add_customer_address,
  //           where: "customerID = ?", whereArgs: [id]).then((value) {
  //     print("val" + value.toString());
  //     if (value.isNotEmpty) {
  //       return value.map((e) => Add_Customer_AddressModel.fromJson(e)).toList();
  //     } else {
  //       return [];
  //     }
  //   });
  //   print("Dynamic:" + _add_customer_addressModel.toString());
  //   return _add_customer_addressModel;
  // }

  // static Future<Add_Customer_AddressModel?> db_getSingle_Add_Customer_Address(
  //     String id) async {
  //   Database _db = await DatabaseHelper.init();
  //   Add_Customer_AddressModel? _add_customer_addressModel = await _db
  //       .query(_table_add_customer_address,
  //           where: "customerID = ?", whereArgs: [id], limit: 1)
  //       .then((value) {
  //     print("val" + value.toString());
  //     if (value.isNotEmpty) {
  //       return value.map((e) => Add_Customer_AddressModel.fromJson(e)).first;
  //     } else {
  //       return null;
  //     }
  //   });
  //   print("Dynamic:" + _add_customer_addressModel.toString());
  //   return _add_customer_addressModel;
  // }

  // static Future<int> db_updateSingle_Add_Customer_Address(
  //     String id, String value) async {
  //   Database _db = await DatabaseHelper.init();
  //   Map<String, dynamic> values = {"isExecuted": value};
  //   return await _db.update(_table_add_customer_address, values,
  //       where: "dbId = ?", whereArgs: [id]);
  // }

/////////////////////////////////////////////////////////////////////

  /// Table Customer Method
  static Future<int> dbInsertCustomer(Customers _customers) async {
    Database _db = await DatabaseHelper.init();
    final row = _customers.toJson();
    return await _db.insert(_tableCustomers, row,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<int> dbInsertAllCustomer(List<Customers>? CustomersList) async {
    Database _db = await DatabaseHelper.init();
    print("Ark-Start");
      Batch batch = _db.batch();

    int index = -1;
    _customers_list!.forEach((element) async {
      final row = element.toJson();
      // index = await _db.insert(_tableCustomers, row);
      batch.insert(_tableCustomers, row);
    });

    await batch.commit(noResult: true);
    print("Ark-End");*/

/*  int index = -1;
     await _db.transaction((txn) async {
      _customers_list?.forEach((element) async {
        final row = element.toJson();
        index = await txn.insert(_tableCustomers, row);
      });
    });
    await _db.transaction((txn) async {
      Batch batch = txn.batch();
      CustomersList?.forEach((element) async {
        final row = element.toJson();
        // index = await txn.insert(_tableCustomerAddress, row);
        batch.insert(_tableCustomers, row);
      });
      await batch.commit(noResult: true);
    });
    return index;
  }

  static Future<int> dbInsertAllCustomerNew(
      List<CompanyCustomers>? CustomersList) async {
    Database _db = await DatabaseHelper.init();
    print("Database Insert Start ");
    int index = -1;
    await _db.transaction((txn) async {
      Batch batch = txn.batch();
      CustomersList?.forEach((element) async {
        final row = element.toJson();
        // index = await txn.insert(_tableCustomerAddress, row);
        batch.insert(_tableCompanyCustomers, row);
      });
      await batch.commit(noResult: true);
    });
    return index;
  }

  static Future<List<Customers>> dbGetAllCustomers() async {
    Database _db = await DatabaseHelper.init();

    /////////////////////////////////////////////
    List<Customers> li = [];
    // Batch batch = _db.batch();
    // batch.query(_tableCustomers);

    // await _db.transaction((txn) async => await txn
    //     .query(_tableCustomers)
    //     .then((value) => value.map((e) => Customers.fromJson(e)).toList()));
    List<Object?> map = [];

    print("Start DateTime:${DateTime.now()}");
    await _db.transaction((txn) async {
      Batch batch = txn.batch();
      batch.query(_tableCustomers);
      map = await batch.commit();
    });
    print("0End DateTime:${DateTime.now()}");

    print("1End DateTime:${DateTime.now()}");
    if (map.isNotEmpty) {
      List<Object> lll = map[0] as List<Object>;
      li = lll.map((e) => Customers.fromJson(e)).toList();
    } else {
      li = [];
    }
    print("2End DateTime:${DateTime.now()}");
    // map[0].map((e) => Customers.fromJson(e)).toList();
    // li.addAll(map as List<Customers>);

    print("map:$map");
    print("Length:${map.length}");

    /////////////////////////////////////////////

    // return await _db
    //     .query(_tableCustomers)
    //     .then((value) => value.map((e) => Customers.fromJson(e)).toList());
    return li;
  }

  static Future<List<Customers>> dbGetAllCustomers1(String value) async {
    Database _db = await DatabaseHelper.init();

    /////////////////////////////////////////////
    List<Customers> li = [];

    try {
      String _query =
          "select * from Customers where Name like  %$value  or CustomerID like %$value";

        li = await _db.query(_tableCustomers,
          where: "Name LIKE ? or CustomerID LIKE ?",
          whereArgs: [
            "%$value",
            "%$value",
          ]).then((value) => value.map((e) => Customers.fromJson(e)).toList());*/

/*

      li = await _db
          .query(_tableCustomers, where: "ContactNo LIKE ?", whereArgs: [
        "%$value%",
      ]).then((value) => value.map((e) => Customers.fromJson(e)).toList());

      int y = 0;
      return li;
    } catch (e) {

      return [];
    }
  }

  static Future<List<CompanyCustomers>> dbGetAllCustomerCompany1(
      String value, int companyId) async {
    Database _db = await DatabaseHelper.init();
    List<CompanyCustomers> li = [];

    try {
      String _query =
          "SELECT * FROM CompanyCustomers WHERE companyId =1 AND Name LIKE '%bahria' OR CustomerID LIKE '%29'";
      li = await _db.query(_tableCompanyCustomers,
          where: "Name LIKE ? or ContactNo LIKE ?",
          whereArgs: [
            "companyId=$companyId",
            "%$value%",
            "%$value%",
          ]).then(
              (value) => value.map((e) => CompanyCustomers.fromJson(e)).toList());

      int y = 0;
      return li;
    } catch (e) {
      return [];
    }
  }

  static Future<List<Customers>> dbGetAllCustomers1(
      String value, int? id) async {
    Database _db = await DatabaseHelper.init();
    List<Customers> li = [];
    try {
      String _query =
          "select * from Customers where Name like  %$value  or CustomerID like %$value";
      // li = await _db
      //     .query(_tableCustomers, where: "ContactNo LIKE ?", whereArgs: [
      //   "%$value%",
      // ]).then((value) => value.map((e) => Customers.fromJson(e)).toList());
      if (id != null) {
        li = await _db.query(_tableCustomers,
            where:
            "companyId = ? AND Name LIKE ? or ContactNo LIKE ? or CustomerID LIKE ?",
            whereArgs: [
              id,
              "%$value%",
              "%$value%",
              "%$value%",
            ]).then(
                (value) => value.map((e) => Customers.fromJson(e)).toList());
      } else {
        li = await _db.query(_tableCustomers,
            where: "Name LIKE ? or ContactNo LIKE ? or CustomerID LIKE ?",
            whereArgs: [
              "%$value%",
              "%$value%",
              "%$value%",
            ]).then(
                (value) => value.map((e) => Customers.fromJson(e)).toList());
      }

      int y = 0;
      return li;
    } catch (e) {
      return [];
    }
  }

  /* static Stream<List<Customers>> dbGetAllCustomers1(String value) async* {
    Database _db = await DatabaseHelper.init();

    /////////////////////////////////////////////
    List<Customers> li = [];

    try {
      String _query =
          "select * from Customers where Name like  %$value  or CustomerID like %$value";

      // li = await _db.query(_tableCustomers,
      //     where: "Name LIKE ? or CustomerID LIKE ?",
      //     whereArgs: [
      //       "%$value",
      //       "%$value",
      //     ]).then((value) => value.map((e) => Customers.fromJson(e)).toList());

      li = await _db
          .query(_tableCustomers, where: "ContactNo LIKE ?", whereArgs: [
        "%$value%",
      ]).then((value) => value.map((e) => Customers.fromJson(e)).toList());

      int y = 0;
      yield li;
    } catch (e) {

      yield [];
    }
  }*/

  static Future<Customers?> dbGetSingleCustomer(String id) async {
    Database _db = await DatabaseHelper.init();
    Customers? _customers = await _db
        .query(_tableCustomers,
        where: "customerID = ?", whereArgs: [id], limit: 1)
        .then((value) {
      print("val$value");
      if (value.isNotEmpty) {
        return value.map((e) => Customers.fromJson(e)).first;
      } else {
        return null;
      }
    });
    print("Dynamic:$_customers");
    return _customers;
  }

  static Future<int?> dbGetAddressId(int id, String defaultAddressId) async {
    Database _db = await DatabaseHelper.init();
    var addressId = (await _db.rawQuery('''
    SELECT id FROM $_tableCustomerAddress WHERE fk_CustomerID = $id AND AddressID = '$defaultAddressId'
    '''));

    if (addressId.isNotEmpty) {
      print(addressId[0]['Id']);
      return addressId[0]['Id'] as int;
    } else {
      return null;
    }
  }

  static Future dbDeleteAllCustomers() async {
    Database _db = await DatabaseHelper.init();
    return _db.delete(_tableCustomers);
  }

  //////////////////////////////////////////////////////////////////////////////

  /// Table Customer Address Method
  static Future<int> dbInsertCustomerAddress(
      CustomerAddresses _customerAddress) async {
    Database _db = await DatabaseHelper.init();
    final row = _customerAddress.toJson();
    return await _db.insert(_tableCustomerAddress, row,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<int> dbInsertAllCustomerAddress(
      List<CustomerAddresses>? CustomerAddressList) async {
    Database _db = await DatabaseHelper.init();
    print("Ark-Start");
    int index = -1;
    /*await _db.transaction((txn) async {
      _customerAddress_list?.forEach((element) async {
        final row = element.toJson();
        index = await txn.insert(_tableCustomerAddress, row);
      });
    });*/
    await _db.transaction((txn) async {
      Batch batch = txn.batch();
      CustomerAddressList?.forEach((element) async {
        final row = element.toJson();
        // index = await txn.insert(_tableCustomerAddress, row);
        batch.insert(_tableCustomerAddress, row);
      });
      await batch.commit(noResult: true);
    });

    print("Ark-End");
    return index;
  }

/*
  static Future<List<CustomerAddresses>> dbGetAllCustomerAddress() async {
    Database _db = await DatabaseHelper.init();
    return await _db.query(_tableCustomerAddress).then(
        (value) => value.map((e) => CustomerAddresses.fromJson(e)).toList());
  }
*/

  static Future<List<CustomerAddresses>> dbGetAllCustomerAddressesByCustomerId(
      int id) async {
    Database _db = await DatabaseHelper.init();
    return await _db.query(_tableCustomerAddress,
        where: "fk_CustomerID = ?",
        whereArgs: [
          id
        ]).then(
            (value) => value.map((e) => CustomerAddresses.fromJson(e)).toList());
  }

  static Future<CustomerAddresses> dbGetAllCustomerAddressSingle(
      String id, String defaultId) async {
    Database _db = await DatabaseHelper.init();
    return await _db.query(_tableCustomerAddress,
        where: "fk_CustomerID = ? and AddressID = ?",
        whereArgs: [
          id,
          defaultId
        ]).then(
            (value) => value.map((e) => CustomerAddresses.fromJson(e)).first);
  }

  static Future<Customers?> dbGetSingleCustomerAddress(String id) async {
    Database _db = await DatabaseHelper.init();
    Customers? _customers = await _db
        .query(_tableCustomerAddress,
        where: "fk_CustomerID = ?", whereArgs: [id], limit: 1)
        .then((value) {
      print("val$value");
      if (value.isNotEmpty) {
        return value.map((e) => Customers.fromJson(e)).first;
      } else {
        return null;
      }
    });
    print("Dynamic:$_customers");
    return _customers;
  }

  static Future dbDeleteAllCustomerAddress() async {
    Database _db = await DatabaseHelper.init();
    return _db.delete(_tableCustomerAddress);
  }

  //////////////////////////////////////////////////////////////////////////////
  /// Table Offline Lead

  static Future<int> dbInsertOfflineLead(MyLeadModel myLeadModel) async {
    Database _db = await DatabaseHelper.init();

    final row = myLeadModel.toJsonDB();
    return await _db
        .insert(_tableOfflineLead, row,
        conflictAlgorithm: ConflictAlgorithm.replace)
        .catchError((onError) {
      return -1;
    });
  }

  static Future<int> db_updateSingleOfflineLead(MyLeadModel myLeadModel) async {
    Database _db = await DatabaseHelper.init();

    return await _db.update(_tableOfflineLead, myLeadModel.toJsonDB(),
        where: "dbId = ?", whereArgs: [myLeadModel.dbId]);
  }

  static Future<int> db_deleteSingleOfflineLead(MyLeadModel myLeadModel) async {
    Database _db = await DatabaseHelper.init();

    return await _db.delete(_tableOfflineLead,
        where: "Id = ?", whereArgs: [myLeadModel.id]).catchError((onError) {
      print("Error $onError");
      return -1;
    });
  }

  static Future<List<MyLeadModel>> dbGetAllOfflineLeadList() async {
    Database _db = await DatabaseHelper.init();
    return await _db
        .query(_tableOfflineLead, orderBy: "dbId DESC")
        .then((value) => value.map((e) => MyLeadModel.fromJsonDB(e)).toList());
  }

  //////////////////////////////////////////////////////////////////////////////

  /// Table Inquiry Saved Method
  /*static Future<int> dbInsertInquirySaved(
      SavedInquiryModel savedInquiryModel) async {
    Database _db = await DatabaseHelper.init();
    final row = savedInquiryModel.toJsonDB();
    return await _db.insert(_tableInquirySaved, row);
  }*/

  static Future<int> dbInsertInquirySaved(
      NewInquirySave savedInquiryModel) async {
    Database _db = await DatabaseHelper.init();

    final row = savedInquiryModel.toJsonDB();
    return await _db.insert(_tableInquirySaved, row,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<int> db_updateSingle_OfflineInquiry(
      int dbID, NewInquirySave savedInquiryModel) async {
    Database _db = await DatabaseHelper.init();

    return await _db.update(_tableInquirySaved, savedInquiryModel.toJsonDB(),
        where: "dbId = ?", whereArgs: [dbID]);
  }

  static Future<int> dbDeleteSingleOfflineInquiry(int dbID) async {
    Database _db = await DatabaseHelper.init();

    return await _db
        .delete(_tableInquirySaved, where: "dbId = ?", whereArgs: [dbID]);
  }

  static Future<List<NewInquirySave>> dbGetAllInquiryList() async {
    Database _db = await DatabaseHelper.init();
    return await _db.query(_tableInquirySaved, orderBy: "dbId DESC").then(
            (value) => value.map((e) => NewInquirySave.fromJsonDB(e)).toList());
  }

  static Future<SavedInquiryModel?> dbGetSingleInquirySaved(String id) async {
    Database _db = await DatabaseHelper.init();
    SavedInquiryModel? savedInquiryRequestModel = await _db
        .query(_tableInquirySaved, where: "Id = ?", whereArgs: [id], limit: 1)
        .then((value) {
      print("val$value");
      if (value.isNotEmpty) {
        return value.map((e) => SavedInquiryModel.fromJsonDB(e)).first;
      } else {
        return null;
      }
    });
    print("Dynamic:$savedInquiryRequestModel");
    return savedInquiryRequestModel;
  }

  static Future dbDeleteAllInquirySaved() async {
    Database _db = await DatabaseHelper.init();
    return _db.delete(_tableInquirySaved);
  }

  /// Table Companies Method
  static Future<int> dbInsertAllCompanies(
      List<Companies>? companiesList) async {
    Database _db = await DatabaseHelper.init();
    // Batch batch = _db.batch();
    int index = -1;
    companiesList!.forEach((element) async {
      final row = element.toJson();
      index = await _db.insert(_tableCompanies, row,
          conflictAlgorithm: ConflictAlgorithm.replace);
      // batch.insert(_tableCompanies, row);
    });
    // await batch.commit(noResult: false);
    return index;
  }

  static Future<List<Companies>> dbGetAllCompanies() async {
    Database _db = await DatabaseHelper.init();
    return await _db
        .query(_tableCompanies)
        .then((value) => value.map((e) => Companies.fromJson(e)).toList());
  }

  static Future<Companies?> dbGetSingleCompanies(String id) async {
    Database _db = await DatabaseHelper.init();
    Companies? _companies = await _db
        .query(_tableCompanies, where: "id = ?", whereArgs: [id], limit: 1)
        .then((value) {
      print("val$value");
      if (value.isNotEmpty) {
        return value.map((e) => Companies.fromJson(e)).first;
      } else {
        return null;
      }
    });
    print("Dynamic:$_companies");
    return _companies;
  }

  static Future dbDeleteAllCompanies() async {
    Database _db = await DatabaseHelper.init();
    return _db.delete(_tableCompanies);
  }

  //////////////////////////////////////////////////////////////////////////////

  /// Table ReferenceSources Method
  static Future<int> dbInsertAllReferenceSources(
      List<ReferenceSources>? _referenceSources) async {
    Database _db = await DatabaseHelper.init();
    // Batch batch = _db.batch();
    int index = -1;
    _referenceSources!.forEach((element) async {
      final row = element.toJson();
      index = await _db.insert(_tableReferenceSources, row,
          conflictAlgorithm: ConflictAlgorithm.replace);
      // batch.insert(_tableReferenceSources, row);
    });
    // await batch.commit(noResult: false);
    return index;
  }

  static Future<List<ReferenceSources>> dbGetAllReferenceSources() async {
    Database _db = await DatabaseHelper.init();
    return await _db.query(_tableReferenceSources).then(
            (value) => value.map((e) => ReferenceSources.fromJson(e)).toList());
  }

  static Future<ReferenceSources?> dbGetSingleReferenceSources(
      String id) async {
    Database _db = await DatabaseHelper.init();
    ReferenceSources? _referenceSources = await _db
        .query(_tableReferenceSources,
        where: "id = ?", whereArgs: [id], limit: 1)
        .then((value) {
      print("val$value");
      if (value.isNotEmpty) {
        return value.map((e) => ReferenceSources.fromJson(e)).first;
      } else {
        return null;
      }
    });
    print("Dynamic:$_referenceSources");
    return _referenceSources;
  }

  static Future dbDeleteAllReferenceSources() async {
    Database _db = await DatabaseHelper.init();
    return _db.delete(_tableReferenceSources);
  }

  //////////////////////////////////////////////////////////////////////////////

  /// Table ReferenceSource Child Method
  static Future<int> dbInsertAllReferenceSourceChild(
      List<ReferenceSourceChild>? _referenceSourceChild) async {
    Database _db = await DatabaseHelper.init();
    // Batch batch = _db.batch();
    int index = -1;
    _referenceSourceChild!.forEach((element) async {
      final row = element.toJson();
      index = await _db.insert(_tableReferenceSourceChild, row,
          conflictAlgorithm: ConflictAlgorithm.replace);
      // batch.insert(_tableReferenceSourceChild, row);
    });
    // await batch.commit(noResult: false);
    return index;
  }

  static Future<List<ReferenceSourceChild>> dbGetAllReferenceSourceChild(
      String id) async {
    Database _db = await DatabaseHelper.init();
    return await _db.query(_tableReferenceSourceChild,
        where: "ReferenceSourceId = ?",
        whereArgs: [
          id
        ]).then(
            (value) => value.map((e) => ReferenceSourceChild.fromJson(e)).toList());
  }

  static Future<ReferenceSourceChild?> dbGetSingleReferenceSourceChild(
      String id) async {
    Database _db = await DatabaseHelper.init();
    ReferenceSourceChild? _referenceSourcechild = await _db
        .query(_tableReferenceSourceChild,
        where: "ReferenceSourceId = ?", whereArgs: [id], limit: 1)
        .then((value) {
      print("val$value");
      if (value.isNotEmpty) {
        return value.map((e) => ReferenceSourceChild.fromJson(e)).first;
      } else {
        return null;
      }
    });
    print("Dynamic:$_referenceSourcechild");
    return _referenceSourcechild;
  }

  static Future dbDeleteAllReferenceSourceChild() async {
    Database _db = await DatabaseHelper.init();
    return _db.delete(_tableReferenceSourceChild);
  }

////////////////////////////////////////////////////////////////////////////////

  /// Table Branches Method
  static Future<int?> dbInsertAllBranches(List<Branches>? _branches) async {
    Database _db = await DatabaseHelper.init();
    // Batch batch = _db.batch();
    int index = -1;
    _branches!.forEach((element) async {
      final row = element.toJson();
      index = await _db.insert(_tableBranches, row,
          conflictAlgorithm: ConflictAlgorithm.replace);
    });
    return index;
  }

  static Future<List<Branches>> dbGetAllBranches() async {
    Database _db = await DatabaseHelper.init();

    return await _db
        .query(_tableBranches)
        .then((value) => value.map((e) => Branches.fromJson(e)).toList());
  }

  static Future<List<Branches>> dbGetAllBranchesByCompanyId(int id) async {
    Database _db = await DatabaseHelper.init();
    var branches = await _db
        .query(_tableBranches, where: "CompanyId= ?", whereArgs: [id]).then(
            (value) => value.map((e) => Branches.fromJson(e)).toList());
    return branches;
  }

  static Future<Branches?> dbGetSingleBranches(String id) async {
    Database _db = await DatabaseHelper.init();
    Branches? _branches = await _db
        .query(_tableBranches, where: "id = ?", whereArgs: [id], limit: 1)
        .then((value) {
      print("val$value");
      if (value.isNotEmpty) {
        return value.map((e) => Branches.fromJson(e)).first;
      } else {
        return null;
      }
    });
    print("Dynamic:$_branches");
    return _branches;
  }

  static Future dbDeleteAllBranches() async {
    Database _db = await DatabaseHelper.init();
    return _db.delete(_tableBranches);
  }

  //////////////////////////////////////////////////////////////////////////////

  /// Table Teams Method
  static Future<int> dbInsertAllTeams(List<Teams>? _teams) async {
    Database _db = await DatabaseHelper.init();
    // Batch batch = _db.batch();
    int index = -1;
    _teams?.forEach((element) async {
      final row = element.toJson();
      index = await _db.insert(_tableTeams, row,
          conflictAlgorithm: ConflictAlgorithm.replace);
      // batch.insert(_tableTeams, row);
    });

    // await batch.commit(noResult: false);
    return index;
  }

  static Future<List<Teams>> dbGetAllTeams() async {
    Database _db = await DatabaseHelper.init();
    return await _db
        .query(_tableTeams)
        .then((value) => value.map((e) => Teams.fromJson(e)).toList());
  }

  static Future<List<Teams>> dbGetAllTeamsByBranchId(int id) async {
    Database _db = await DatabaseHelper.init();
    return await _db.query(_tableTeams, where: "BranchId= ?", whereArgs: [
      id
    ]).then((value) => value.map((e) => Teams.fromJson(e)).toList());
  }

  static Future<Teams?> dbGetSingleTeams(String id) async {
    Database _db = await DatabaseHelper.init();
    Teams? _teams = await _db
        .query(_tableTeams, where: "id = ?", whereArgs: [id], limit: 1)
        .then((value) {
      print("val$value");
      if (value.isNotEmpty) {
        return value.map((e) => Teams.fromJson(e)).first;
      } else {
        return null;
      }
    });
    print("Dynamic:$_teams");
    return _teams;
  }

  static Future dbDeleteAllTeams() async {
    Database _db = await DatabaseHelper.init();
    return _db.delete(_tableTeams);
  }

  //////////////////////////////////////////////////////////////////////////////

  /// Table Team Members Methods
  static Future<int> dbInsertAllTeamMembers(
      List<TeamMembers>? _teamMembers) async {
    Database _db = await DatabaseHelper.init();
    int index = -1;
    _teamMembers!.forEach((element) async {
      final row = element.toJson();
      index = await _db.insert(_tableTeamMembers, row,
          conflictAlgorithm: ConflictAlgorithm.replace);
    });
    return index;
  }

  static Future<List<TeamMembers>> dbGetAllTeamMembers() async {
    Database _db = await DatabaseHelper.init();
    return await _db
        .query(_tableTeamMembers)
        .then((value) => value.map((e) => TeamMembers.fromJson(e)).toList());
  }

  static Future<List<TeamMembers>> dbGetAllTeamMembersByTeamId(
      String id) async {
    Database _db = await DatabaseHelper.init();
    var data = _db.query(_tableTeamMembers,
        where: "TeamIds Like ?", whereArgs: ["%$id%"]);

    return await _db
        .query(_tableTeamMembers, where: "TeamIds LIKE ?", whereArgs: [
      "%$id%"
    ]).then((value) => value.map((e) => TeamMembers.fromJsonDB(e)).toList());
  }

  static Future<TeamMembers?> dbGetSingleTeamMember(String id) async {
    Database _db = await DatabaseHelper.init();
    TeamMembers? _teamMember = await _db
        .query(_tableTeamMembers, where: "Id = ?", whereArgs: [id], limit: 1)
        .then((value) {
      print("val$value");
      if (value.isNotEmpty) {
        return value.map((e) => TeamMembers.fromJson(e)).first;
      } else {
        return null;
      }
    });
    print("Dynamic:$_teamMember");
    return _teamMember;
  }

  static Future dbDeleteAllTeamMembers() async {
    Database _db = await DatabaseHelper.init();
    return _db.delete(_tableTeamMembers);
  }

  //////////////////////////////////////////////////////////////////////////////

  /// Table Schedule Duration Method
  static Future<int> dbInsertAllScheduleDuration(
      List<ScheduleDurationModel>? _scheduleDurationModel) async {
    Database _db = await DatabaseHelper.init();
    Batch batch = _db.batch();
    int index = -1;
    _scheduleDurationModel!.forEach((element) async {
      final row = element.toJson();
      batch.insert(_tableMeetingTypes, row);
    });

    await batch.commit(noResult: false);
    return index;
  }

  static Future<List<ScheduleDurationModel>> dbGetAllScheduleDuration() async {
    Database _db = await DatabaseHelper.init();
    return await _db.query(_tableMeetingTypes).then((value) =>
        value.map((e) => ScheduleDurationModel.fromJson(e)).toList());
  }

  //////////////////////////////////////////////////////////////////////////////

  /// Table Meeting Types Method
  static Future<int> dbInsertAllMeetingTypes(
      List<MeetingTypes>? _meetingTypes) async {
    Database _db = await DatabaseHelper.init();
    Batch batch = _db.batch();
    int index = -1;
    _meetingTypes!.forEach((element) async {
      final row = element.toJson();
      batch.insert(_tableMeetingTypes, row);
    });

    await batch.commit(noResult: false);
    return index;
  }

  static Future<List<MeetingTypes>> dbGetAllMeetingTypes() async {
    Database _db = await DatabaseHelper.init();
    return await _db
        .query(_tableMeetingTypes)
        .then((value) => value.map((e) => MeetingTypes.fromJson(e)).toList());
  }

  static Future<MeetingTypes?> dbGetSingleMeetingTypes(String id) async {
    Database _db = await DatabaseHelper.init();
    MeetingTypes? _meetingTypes = await _db
        .query(_tableMeetingTypes, where: "id = ?", whereArgs: [id], limit: 1)
        .then((value) {
      print("val$value");
      if (value.isNotEmpty) {
        return value.map((e) => MeetingTypes.fromJson(e)).first;
      } else {
        return null;
      }
    });
    print("Dynamic:$_meetingTypes");
    return _meetingTypes;
  }

  static Future dbDeleteAllMeetingTypes() async {
    Database _db = await DatabaseHelper.init();
    return _db.delete(_tableMeetingTypes);
  }

////////////////////////////////////////////////////////////////////////////////
  // LeadStatus
  static Future<int> dbInsertAllLeadStatus(
      List<LeadStatuses>? leadStatuses) async {
    Database _db = await DatabaseHelper.init();
    int index = -1;
    await _db.transaction((txn) async {
      // Batch batch = txn.batch();
      leadStatuses?.forEach((element) async {
        final row = element.toJson();
        // batch.insert(_tableLeadStatus, row);
        await txn.insert(_tableLeadStatus, row);
      });
      // await batch.commit(noResult: true);
    });
    return index;
  }

  static Future dbGetSingleLeadStatusById(int id) async {
    Database _db = await DatabaseHelper.init();
    var data = _db.query("SELECT Status FROM LeadStatus WHERE Id=$id");
    print(data);
  }

  static Future<List<LeadStatuses>> db_getAllLeadStatuses() async {
    Database _db = await DatabaseHelper.init();

    return await _db
        .rawQuery('SELECT * FROM $_tableLeadStatus')
        .then((value) => value.map((e) => LeadStatuses.fromJson(e)).toList());
  }

  static Future dbDeleteAllLeadStatus() async {
    Database _db = await DatabaseHelper.init();
    return _db.delete(_tableLeadStatus);
  }

////////////////////////////////////////////////////////////////////////////////
  // Cities

  static Future<List<String>> db_getAllCities() async {
    Database _db = await DatabaseHelper.init();
    return await _db
        .rawQuery('SELECT * FROM $_tableCities')
        .then((value) => value.map((e) => e["Name"].toString()).toList());
  }

  static Future<int> dbInsertAllCities(List<String>? cities) async {
    Database _db = await DatabaseHelper.init();
    int index = -1;
    await _db.transaction((txn) async {
      // Batch batch = txn.batch();
      cities?.forEach((element) async {
        final row = {"Name": element};
        // batch.insert(_tableCities, row);
        await txn.insert(_tableCities, row);
      });
      // await batch.commit(noResult: true);
    });
    return index;
  }

  static Future dbDeleteAllCities() async {
    Database _db = await DatabaseHelper.init();
    return _db.delete(_tableCities);
  }

////////////////////////////////////////////////////////////////////////////////
  // Unit of Measurement
  static Future<int> dbInsertAllUnitOfMeasurement(
      List<UnitOfMeasurmentData>? unitOfMeasurement) async {
    Database _db = await DatabaseHelper.init();
    int index = -1;
    await _db.transaction((txn) async {
      // Batch batch = txn.batch();
      unitOfMeasurement?.forEach((element) async {
        final row = element.toJson();
        // batch.insert(_tableUnitOfMeasurement, row);
        await txn.insert(_tableUnitOfMeasurement, row);
      });
      // await batch.commit(noResult: true);
    });
    return index;
  }

  static Future<List<UnitOfMeasurmentData>> db_getAllUnitOFMeasurement() async {
    Database _db = await DatabaseHelper.init();
    return await _db.rawQuery('SELECT * FROM $_tableUnitOfMeasurement').then(
            (value) => value.map((e) => UnitOfMeasurmentData.fromJson(e)).toList());
  }

  static Future dbDeleteAllUnitOfMeasurement() async {
    Database _db = await DatabaseHelper.init();
    return _db.delete(_tableUnitOfMeasurement);
  }

////////////////////////////////////////////////////////////////////////////////
  ///Payment Durations
  static Future<int> dbInsertAllPaymentDuration(
      List<PaymentDurations>? paymentDurations) async {
    Database _db = await DatabaseHelper.init();
    int index = -1;
    await _db.transaction((txn) async {
      // Batch batch = txn.batch();
      paymentDurations?.forEach((element) async {
        final row = element.toJson();
        // batch.insert(_tableUnitOfMeasurement, row);
        await txn.insert(_tablePaymentDurations, row);
      });
      // await batch.commit(noResult: true);
    });
    return index;
  }

  static Future<List<PaymentDurations>> db_getAllPaymentDurations() async {
    Database _db = await DatabaseHelper.init();
    return await _db.rawQuery('SELECT * FROM $_tablePaymentDurations').then(
            (value) => value.map((e) => PaymentDurations.fromJson(e)).toList());
  }

  static Future dbDeleteAllPaymentDurations() async {
    Database _db = await DatabaseHelper.init();
    return _db.delete(_tablePaymentDurations);
  }

////////////////////////////////////////////////////////////////////////////////
  //All Complaints
  static Future dbInsertAllComplaints(
      List<AllComplaintsData>? allComplaintsList) async {
    Database _db = await DatabaseHelper.init();
    int index = -1;
    await _db.transaction((txn) async {
      allComplaintsList?.forEach((element) async {
        final row = element.toJsonDB();
        await txn.insert(_tableAllComplaints, row,
            conflictAlgorithm: ConflictAlgorithm.replace);
      });
    });
    return index;
  }

  static Future<List<AllComplaintsData>> dbGetAllComplaints() async {
    Database _db = await DatabaseHelper.init();
    return await _db.rawQuery('SELECT * FROM $_tableAllComplaints').then(
            (value) => value.map((e) => AllComplaintsData.fromJsonDB(e)).toList());
  }

  static Future dbInsertSingleComplaints(AllComplaintsData complaint) async {
    Database _db = await DatabaseHelper.init();
    int index = -1;
    await _db.transaction((txn) async {
      final row = complaint.toJson();
      await txn.insert(
        _tableAllComplaints,
        row,
      );
    });
    return index;
  }

  static Future<AllComplaintsData?> dbGetSingleComplaints(int id) async {
    Database _db = await DatabaseHelper.init();
    AllComplaintsData? allComplaintsData = await _db
        .query(_tableAllComplaints, where: "id = ?", whereArgs: [id], limit: 1)
        .then((value) {
      print("val$value");
      if (value.isNotEmpty) {
        return value.map((e) => AllComplaintsData.fromJsonDB(e)).first;
      } else {
        return null;
      }
    });
    return allComplaintsData;
  }

  static Future dbDeleteAllComplaints() async {
    Database _db = await DatabaseHelper.init();
    return _db.delete(_tableAllComplaints);
  }

////////////////////////////////////////////////////////////////////////////////
  ///My Leads
  static Future dbInsertAllMyLeads(List<MyLeadModel>? myLeadsList) async {
    Database _db = await DatabaseHelper.init();
    int index = -1;
    await _db.transaction((txn) async {
      myLeadsList?.forEach((element) async {
        final row = element.toJsonDB();
        await txn.insert(_tableMyLeads, row,
            conflictAlgorithm: ConflictAlgorithm.replace);
      });
    });
    return index;
  }

  static Future dbInsertSingleMyLead(MyLeadModel model) async {
    Database _db = await DatabaseHelper.init();
    final row = model.toJsonDB();
    await _db.insert(_tableMyLeads, row,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<List<MyLeadModel?>> dbGetAllMyLeads() async {
    Database _db = await DatabaseHelper.init();
    return await _db
        .rawQuery('SELECT * FROM $_tableMyLeads')
        .then((value) => value.map((e) => MyLeadModel.fromJsonDB(e)).toList());
  }

  static Future<MyLeadModel?> dbGetSingleMyLeadById(int id) async {
    Database _db = await DatabaseHelper.init();
    MyLeadModel? model = await _db
        .query(_tableMyLeads, where: 'Id = ?', whereArgs: [id], limit: 1)
        .then((value) {
      if (value.isNotEmpty) {
        return value.map((e) => MyLeadModel.fromJsonDB(e)).first;
      } else {
        return null;
      }
    });
    return model;
  }

  static Future dbUpdateSingleLeadFromMyLeads(MyLeadModel myLeadModel) async {
    Database _db = await DatabaseHelper.init();
    return await _db.update(_tableMyLeads, myLeadModel.toJsonDB(),
        where: "id = ?", whereArgs: [myLeadModel.id]);
  }

  static Future dbDeleteAllMyLeads() async {
    Database _db = await DatabaseHelper.init();
    return _db.delete(_tableMyLeads);
  }

////////////////////////////////////////////////////////////////////////////////
  ///Global Leads
  static Future dbInsertAllGlobalLeads(List<MyLeadModel>? myLeadsList) async {
    Database _db = await DatabaseHelper.init();
    int index = -1;
    await _db.transaction((txn) async {
      myLeadsList?.forEach((element) async {
        final row = element.toJsonDB();
        await txn.insert(_tableGlobalLeads, row,
            conflictAlgorithm: ConflictAlgorithm.replace);
      });
    });
    return index;
  }

  static Future<List<MyLeadModel?>> dbGetAllGlobalLeads() async {
    Database _db = await DatabaseHelper.init();
    return await _db
        .rawQuery('SELECT * FROM $_tableMyLeads')
        .then((value) => value.map((e) => MyLeadModel.fromJsonDB(e)).toList());
  }

  static Future dbUpdateSingleLeadFromGlobalLeads(
      MyLeadModel myLeadModel) async {
    Database _db = await DatabaseHelper.init();
    return await _db.update(_tableMyLeads, myLeadModel.toJsonDB(),
        where: "id = ?", whereArgs: [myLeadModel.id]);
  }

  static Future dbDeleteAllGlobalLeads() async {
    Database _db = await DatabaseHelper.init();
    return _db.delete(_tableMyLeads);
  }

////////////////////////////////////////////////////////////////////////////////
  ///Inquiry Meetings
  static Future dbInsertSingleInquiryMeeting(
      SaveMeetingRequestModel model) async {
    Database _db = await DatabaseHelper.init();
    _db.insert(_tableInquiryMeetings, model.toJsonDB(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  ///GET TASK BY DB ID
  static Future<SaveMeetingRequestModel?> dbGetSingleInquiryMeetingByDbId(
      int dbId) async {
    Database _db = await DatabaseHelper.init();
    SaveMeetingRequestModel? model = await _db
        .query(_tableInquiryMeetings,
        where: 'dbID = ?', whereArgs: [dbId], limit: 1)
        .then((value) {
      if (value.isNotEmpty) {
        return value.map((e) => SaveMeetingRequestModel.fromJsonDB(e)).first;
      } else {
        return null;
      }
    });
    return model;
  }

  ///GET TASK BY TASK ID
  static Future<SaveMeetingRequestModel?> dbGetSingleInquiryMeetingById(
      int Id) async {
    Database _db = await DatabaseHelper.init();
    SaveMeetingRequestModel? model = await _db
        .query(_tableInquiryMeetings,
        where: 'Id = ?', whereArgs: [Id], limit: 1)
        .then((value) {
      if (value.isNotEmpty) {
        return value.map((e) => SaveMeetingRequestModel.fromJsonDB(e)).first;
      } else {
        return null;
      }
    });
    return model;
  }

  ///DELETE SINGLE TASK BY dbID
  static Future dbDeleteSingleInquiryMeetingByDbId(int id) async {
    Database _db = await DatabaseHelper.init();
    _db.delete(_tableInquiryMeetings, where: 'dbId = ?', whereArgs: [id]);
  }

  ///DELETE SINGLE TASK BY INQUIRY ID
  static Future dbDeleteSingleInquiryMeetingByInquiryId(int id) async {
    Database _db = await DatabaseHelper.init();
    _db.delete(_tableInquiryMeetings, where: 'Id = ?', whereArgs: [id]);
  }

  ///Update Single Task By Db Id
  static Future dbUpdateInquiryMeetingByDbId(
      {required int id, required SaveMeetingRequestModel model}) async {
    Database _db = await DatabaseHelper.init();
    final row = model.toJsonDB();
    _db.update(_tableInquiryMeetings, row, where: 'dbId = ?', whereArgs: [id]);
  }

  ///Get Tasks By Date and Id
  static Future<List<SaveMeetingRequestModel>>
  dbGetAllInquiryMeetingsByDateAndLeadId(String date, int leadId) async {
    Database _db = await DatabaseHelper.init();
    return await _db
        .rawQuery(
        'SELECT * FROM $_tableInquiryMeetings WHERE LeadManagementId=$leadId AND StartingTime LIKE "%$date%"')
        .then((value) =>
        value.map((e) => SaveMeetingRequestModel.fromJsonDB(e)).toList());
  }

  static Future dbUpdateInquiryMeetingById(
      {required int id, required SaveMeetingRequestModel model}) async {
    Database _db = await DatabaseHelper.init();
    final row = model.toJsonDB();
    _db.update(_tableInquiryMeetings, row, where: 'Id = ?', whereArgs: [id]);
  }

  static Future<List<SaveMeetingRequestModel?>> dbGetAllInquiryMeetingsById(
      int id) async {
    Database _db = await DatabaseHelper.init();
    return await _db
        .rawQuery(
        'SELECT * FROM $_tableInquiryMeetings WHERE LeadManagementId=$id')
        .then((value) =>
        value.map((e) => SaveMeetingRequestModel.fromJsonDB(e)).toList());
  }

  static Future<List<SaveMeetingRequestModel?>>
  dbGetAllInquiryMeetings() async {
    Database _db = await DatabaseHelper.init();
    return await _db.rawQuery('SELECT * FROM $_tableInquiryMeetings').then(
            (value) =>
            value.map((e) => SaveMeetingRequestModel.fromJsonDB(e)).toList());
  }

  static Future dbInsertAllInquiryMeetings(
      List<SaveMeetingRequestModel>? inquiryMeetingsList) async {
    Database _db = await DatabaseHelper.init();
    int index = -1;
    await _db.transaction((txn) async {
      inquiryMeetingsList?.forEach((element) async {
        final row = element.toJsonDB();
        await txn.insert(_tableInquiryMeetings, row,
            conflictAlgorithm: ConflictAlgorithm.replace);
      });
    });
    return index;
  }

  static Future dbDeleteAllInquiryMeetings() async {
    Database _db = await DatabaseHelper.init();
    return _db.delete(_tableInquiryMeetings);
  }

////////////////////////////////////////////////////////////////////////////////
  ///My Targets
  static Future dbInsertAllMyTargets(List<AllTargetData> list) async {
    Database _db = await DatabaseHelper.init();
    int index = -1;
    await _db.transaction((txn) async {
      list.forEach((element) async {
        final row = element.toJsonDB();
        await txn.insert(_tableMyTargets, row,
            conflictAlgorithm: ConflictAlgorithm.replace);
      });
    });
    return index;
  }

  static Future<List<AllTargetData>> dbGetAllMyTargets() async {
    Database _db = await DatabaseHelper.init();
    return await _db.rawQuery('SELECT * FROM $_tableMyTargets').then(
            (value) => value.map((e) => AllTargetData.fromJsonDB(e)).toList());
  }

  static Future dbDeleteAllMyTargets() async {
    Database _db = await DatabaseHelper.init();
    return _db.delete(_tableMyTargets);
  }

////////////////////////////////////////////////////////////////////////////////
  ///OFFLINE Complaint status Update
  static Future dbInsertSingleOfflineComplaintStatusUpdate(
      ComplaintStatusUpdateModel model) async {
    Database _db = await DatabaseHelper.init();
    _db.insert(_tableOfflineComplaintStatusUpdate, model.toJsonDB(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<ComplaintStatusUpdateModel?>
  dbGetSingleOfflineComplaintStatusUpdate(int dbId) async {
    Database _db = await DatabaseHelper.init();
    ComplaintStatusUpdateModel? model = await _db
        .query(_tableOfflineComplaintStatusUpdate,
        where: 'WHERE dbID = ?', whereArgs: [dbId], limit: 1)
        .then((value) {
      if (value.isNotEmpty) {
        return value.map((e) => ComplaintStatusUpdateModel.fromJsonDB(e)).first;
      } else {
        return null;
      }
    });
    return model;
  }

  static Future<List<ComplaintStatusUpdateModel>>
  dbGetAllOfflineComplaintStatusUpdate() async {
    Database _db = await DatabaseHelper.init();
    return await _db
        .rawQuery('SELECT * FROM $_tableOfflineComplaintStatusUpdate')
        .then((value) => value
        .map((e) => ComplaintStatusUpdateModel.fromJsonDB(e))
        .toList());
  }

  static Future dbDeleteSingleSingleOfflineComplaintStatusUpdateById(
      int id) async {
    Database _db = await DatabaseHelper.init();
    _db.delete(_tableOfflineComplaintStatusUpdate,
        where: 'Id = ?', whereArgs: [id]);
  }

  static Future dbDeleteAllOfflineComplaintStatusUpdate() async {
    Database _db = await DatabaseHelper.init();
    return _db.delete(_tableOfflineComplaintStatusUpdate);
  }

////////////////////////////////////////////////////////////////////////////////
  ///OFFLINE TASKS
  static Future dbInsertSingleOfflineTask(SaveMeetingRequestModel model) async {
    Database _db = await DatabaseHelper.init();
    int id = await _db.insert(_tableOfflineTasks, model.toJsonDB(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    print(id);
  }

  ///Get Tasks By Date and Id
  static Future<List<SaveMeetingRequestModel>>
  dbGetAllOfflineTasksByDateAndLeadId(String date, int leadId) async {
    Database _db = await DatabaseHelper.init();
    return await _db
        .rawQuery(
        'SELECT * FROM $_tableOfflineTasks WHERE LeadManagementId=$leadId AND StartingTime LIKE "%$date%"')
        .then((value) =>
        value.map((e) => SaveMeetingRequestModel.fromJsonDB(e)).toList());
  }

  ///GET TASK BY DB ID
  static Future<SaveMeetingRequestModel?> dbGetSingleOfflineTaskByDbId(
      int dbId) async {
    Database _db = await DatabaseHelper.init();
    SaveMeetingRequestModel? model = await _db
        .query(_tableOfflineTasks,
        where: 'dbID = ?', whereArgs: [dbId], limit: 1)
        .then((value) {
      if (value.isNotEmpty) {
        return value.map((e) => SaveMeetingRequestModel.fromJsonDB(e)).first;
      } else {
        return null;
      }
    });
    return model;
  }

  ///GET TASK BY TASK ID
  static Future<SaveMeetingRequestModel?> dbGetSingleOfflineTaskById(
      int Id) async {
    Database _db = await DatabaseHelper.init();
    SaveMeetingRequestModel? model = await _db
        .query(_tableOfflineTasks, where: 'Id = ?', whereArgs: [Id], limit: 1)
        .then((value) {
      if (value.isNotEmpty) {
        return value.map((e) => SaveMeetingRequestModel.fromJsonDB(e)).first;
      } else {
        return null;
      }
    });
    return model;
  }

  ///DELETE SINGLE TASK BY dbID
  static Future dbDeleteSingleOfflineTaskByDbId(int id) async {
    Database _db = await DatabaseHelper.init();
    _db.delete(_tableOfflineTasks, where: 'dbId = ?', whereArgs: [id]);
  }

  ///DELETE SINGLE TASK BY INQUIRY ID
  static Future dbDeleteSingleOfflineTaskByInquiryId(int id) async {
    Database _db = await DatabaseHelper.init();
    _db.delete(_tableOfflineTasks, where: 'Id = ?', whereArgs: [id]);
  }

  ///Update Single Task By Db Id
  static Future dbUpdateOfflineTaskByDbId(
      {required int id, required SaveMeetingRequestModel model}) async {
    Database _db = await DatabaseHelper.init();
    final row = model.toJsonDB();
    _db.update(_tableOfflineTasks, row, where: 'dbId = ?', whereArgs: [id]);
  }

  static Future dbUpdateOfflineTaskById(
      {required int id, required SaveMeetingRequestModel model}) async {
    Database _db = await DatabaseHelper.init();
    final row = model.toJsonDB();
    _db.update(_tableOfflineTasks, row, where: 'Id = ?', whereArgs: [id]);
  }

  static Future<List<SaveMeetingRequestModel?>> dbGetAllOfflineTasksById(
      int id) async {
    Database _db = await DatabaseHelper.init();
    return await _db
        .rawQuery(
        'SELECT * FROM $_tableOfflineTasks WHERE LeadManagementId=$id ORDER BY dbId ASC')
        .then((value) =>
        value.map((e) => SaveMeetingRequestModel.fromJsonDB(e)).toList());
  }

  static Future<List<SaveMeetingRequestModel>> dbGetAllOfflineTasks() async {
    Database _db = await DatabaseHelper.init();
    return await _db.rawQuery('SELECT * FROM $_tableOfflineTasks').then(
            (value) =>
            value.map((e) => SaveMeetingRequestModel.fromJsonDB(e)).toList());
  }

  static Future dbInsertAllOfflineTasks(
      List<SaveMeetingRequestModel>? inquiryMeetingsList) async {
    Database _db = await DatabaseHelper.init();
    int index = -1;
    await _db.transaction((txn) async {
      inquiryMeetingsList?.forEach((element) async {
        final row = element.toJsonDB();
        await txn.insert(_tableOfflineTasks, row,
            conflictAlgorithm: ConflictAlgorithm.replace);
      });
    });
    return index;
  }

  static Future dbDeleteAllOfflineTasks() async {
    Database _db = await DatabaseHelper.init();
    return _db.delete(_tableOfflineTasks);
  }

  //////////////////////////////////////////////////////////////////////////////
  ///Products By Companies
  static Future dbInsertAllProductsByCompanyId(
      List<Product> products, int id) async {
    Database _db = await DatabaseHelper.init();
    int index = -1;
    await _db.transaction((txn) async {
      products.forEach((element) async {
        element.companyId = id;
        final row = element.toJsonDB();
        await txn.insert(_tableAllProducts, row,
            conflictAlgorithm: ConflictAlgorithm.replace);
      });
    });
    return index;
  }

  static Future<List<Product>> dbGetAllProductsByCompanyId(int id) async {
    Database _db = await DatabaseHelper.init();
    return await _db
        .rawQuery('SELECT * FROM $_tableAllProducts WHERE companyId = $id')
        .then((value) => value.map((e) => Product.fromJsonDB(e)).toList());
  }

  static Future dbDeleteAllProducts() async {
    Database _db = await DatabaseHelper.init();
    return _db.delete(_tableAllProducts);
  }
}

*/
