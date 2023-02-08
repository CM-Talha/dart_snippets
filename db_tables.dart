mixin DbTables {
  //Table Names
  static const String testTable = "test_table";
  static const String offlineActivities = "offline_Activities";
  static const String schoolsTable = "schools_table";
  static const String cityTable = "city_table";

  //Table Create Queries
  static const String testTableCreateQuery = """
  CREATE TABLE $testTable (
            dbID INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT ,
            mobile_no TEXT ,
            phone_no TEXT ,
            customer_email TEXT ,
            customer_address TEXT
          )
  """;

  static const String offlineActivitiesCreateQuery = """
  CREATE TABLE $offlineActivities (
            dbID INTEGER PRIMARY KEY AUTOINCREMENT,
            id INTEGER,
            activityName TEXT ,
            activityType TEXT ,
            anchorId INTEGER ,
            anchorName TEXT ,
            assignedBy TEXT ,
            schoolId INTEGER ,
            schoolName TEXT ,
            schoolAddress TEXT ,
            activityStatus INTEGER,
            modifiedOn TEXT,
            createdOn TEXT,
            createdBy INTEGER,
            cityId INTEGER,
            cityName TEXT,
            isExecuted INTEGER,
            audioFilePath TEXT
          )
  """;
  static const String schoolsTableCreateQuery = """
  CREATE TABLE $schoolsTable (
            dbID INTEGER PRIMARY KEY AUTOINCREMENT,
            id INTEGER ,
            schoolName TEXT ,
            branchId INTEGER,
            branchName TEXT ,
            address TEXT ,
            cityId INTEGER,
            cityName TEXT,
            isActive INTEGER
          );
  """;
  static const String cityTableCreateQuery = """
  CREATE TABLE $cityTable (
            dbID INTEGER PRIMARY KEY AUTOINCREMENT,
            id INTEGER ,
            cityName TEXT,
            isActive INTEGER
          );
  """;

  /*
  INSERT INTO test_table (name, mobile_no, phone_no, customer_email, customer_address) VALUES ("User 2", "03331234567", "03331234567", "user2@example.com", "User 2 Address")
   */
}
