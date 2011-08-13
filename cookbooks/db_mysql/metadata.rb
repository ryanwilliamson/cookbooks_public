maintainer       "RightScale, Inc."
maintainer_email "support@rightscale.com"
license          IO.read(File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'LICENSE')))
description      "Installs/configures a MySQL database server with automated backups."
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version          "0.0.1"

provides "db_mysql_restore(url, branch, user, credentials, file_path, schema_name, tmp_dir)"
provides "db_mysql_set_privileges(type, username, password, db_name)"
provides "db_mysql_gzipfile_backup(db_name, file_path)"
provides "db_mysql_gzipfile_restore(db_name, file_path)"

recipe  "db_mysql::default", "Runs the client 'install_mysql' recipes."
recipe  "db_mysql::install_client", "Installs the MySQL 5.1 client packages and gem."
recipe  "db_mysql::install_client_5.0", "Installs the MySQL 5.0 client packages and gem."
recipe  "db_mysql::install_mysql", "Installs the packages that are required for MySQL servers."
recipe  "db_mysql::setup_mysql", "Configures the MySQL server."
recipe  "db_mysql::setup_admin_privileges", "Adds the username and password for 'superuser' privileges."
recipe  "db_mysql::setup_application_privileges", "Adds username and password for application privileges."
recipe  "db_mysql::setup_my_cnf", "Creates the my.cnf configuration file."
recipe  "db_mysql::do_dump_import", "Initializes the MySQL database with a dumpfile from the specified cloud storage location. (i.e. S3, cloudfiles)"
recipe  "db_mysql::do_dump_export", "Uploads a MySQL dumpfile archive to the specified cloud storage location. (i.e. S3, cloudfiles)"
recipe  "db_mysql::setup_continuous_export", "Schedules the daily run of do_dump_export."
recipe  "db_mysql::setup_monitoring", "Install collectd-mysql for monitoring support"


attribute "db_mysql",
  :display_name => "General Database Options",
  :type => "hash"
  
attribute "db_mysql/admin/user",
  :display_name => "Database Admin Username",
  :description => "The username of the database user that has 'admin' privileges.",
  :required => true,
  :recipes => [ "db_mysql::setup_admin_privileges", "db_mysql::do_backup" ]

attribute "db_mysql/admin/password",
  :display_name => "Database Admin Password",
  :description => "The password of the database user that has 'admin' privileges.",
  :required => true,
  :recipes => [ "db_mysql::setup_admin_privileges", "db_mysql::do_backup" ]
  
attribute "db_mysql/application/user",
  :display_name => "Database Application Username",
  :description => "The username of the database user that has 'user' privileges.",
  :required => true,
  :recipes => [ "db_mysql::default", "db_mysql::setup_application_privileges" ]

attribute "db_mysql/application/password",
  :display_name => "Database Application Password",
  :description => "The password of the database user that has 'user' privileges.",
  :required => true,
  :recipes => [ "db_mysql::default", "db_mysql::setup_application_privileges" ]

  

# == Import/export Attributes
#
attribute "db_mysql/dump",
  :display_name => "Import/Export settings for MySQL dump file management.",
  :type => "hash"

attribute "db_mysql/dump/schema_name",
  :display_name => "Schema Name",
  :description => "Enter the name of the MySQL database schema to which applications will connect.  The database schema was created when the initial database was first set up.  This input will be used to set the application server's database config file so that applications can connect to the correct schema within the database.  This input is also used for MySQL dump backups in order to determine which schema is getting backed up.  Ex: mydbschema",
  :required => true,
  :recipes => [ "db_mysql::do_dump_import", "db_mysql::do_dump_export", "db_mysql::setup_continuous_export"  ]

attribute "db_mysql/dump/storage_account_provider",
  :display_name => "Storage Account Provider",
  :description => "Select the cloud infrastructure where the backup will be saved. For Amazon S3, use ec2.  For Rackspace Cloud Files, use rackspace.",
  :required => true,
  :recipes => [ "db_mysql::do_dump_import", "db_mysql::do_dump_export", "db_mysql::setup_continuous_export"  ]

attribute "db_mysql/dump/storage_account_id",
  :display_name => "Storage Account Id",
  :description => "In order to write the dump file to the specified cloud storage location, you will need to provide cloud authentication credentials. For Amazon S3, use AWS_ACCESS_KEY_ID. For Rackspace Cloud Files, use your Rackspace login Username.",
  :required => true,
  :recipes => [ "db_mysql::do_dump_import", "db_mysql::do_dump_export", "db_mysql::setup_continuous_export"  ]

attribute "db_mysql/dump/storage_account_secret",
  :display_name => "Storage Account Secret",
  :description => "In order to write the dump file to the specified cloud storage location, you will need to provide cloud authentication credentials. For Amazon S3, use AWS_SECRET_ACCESS_KEY. For Rackspace Cloud Files, use your Rackspace account API Key.",
  :required => true,
  :recipes => [ "db_mysql::do_dump_import", "db_mysql::do_dump_export", "db_mysql::setup_continuous_export"  ]

attribute "db_mysql/dump/container",
  :display_name => "Container",
  :description => "The cloud storage location where the MySQL dump file will be saved to or restored from. For Amazon S3, use the bucket name.  For Rackspace Cloud Files, use the container name.",
  :required => true,
  :recipes => [ "db_mysql::do_dump_import", "db_mysql::do_dump_export", "db_mysql::setup_continuous_export"  ]

attribute "db_mysql/dump/prefix",
  :display_name => "Prefix",
  :description => "The prefix that will be used to name/locate the backup of a particular MySQL database.  Defines the prefix of the MySQL dump filename that will be used to name the backup database dumpfile along with a timestamp.",
  :required => true,
  :recipes => [ "db_mysql::do_dump_import", "db_mysql::do_dump_export", "db_mysql::setup_continuous_export"  ]

#
# recommended attributes
#
attribute "db_mysql/server_usage",
  :display_name => "Server Usage",
  :description => "Use 'dedicated' if the mysql config file allocates all existing resources of the machine.  Use 'shared' if the MySQL config file is configured to use less resources so that it can be run concurrently with other apps like Apache and Rails for example.",
  :recipes => [
                "db_mysql::install_mysql"
              ],
  :choice => ["shared", "dedicated"],
  :default => "dedicated"

#
# optional attributes
#
attribute "db_mysql/log_bin",
  :display_name => "MySQL Binlog Destination",
  :description => "Defines the filename and location of your MySQL stored binlog files.  This sets the log-bin variable in the MySQL config file.  If you do not specify an absolute path, it will be relative to the data directory.",
  :recipes => [ "db_mysql::setup_mysql" ],
  :default => "/mnt/mysql-binlogs/mysql-bin"
 
