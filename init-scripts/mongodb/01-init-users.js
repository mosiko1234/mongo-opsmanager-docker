// MongoDB initialization script for Ops Manager
// This script creates the necessary users and databases

print('Starting MongoDB initialization for Ops Manager...');

// Switch to admin database
db = db.getSiblingDB('admin');

// Create dedicated user for Ops Manager
db.createUser({
  user: 'opsmanager',
  pwd: 'opsmanager123',
  roles: [
    { role: 'readWriteAnyDatabase', db: 'admin' },
    { role: 'clusterAdmin', db: 'admin' },
    { role: 'userAdminAnyDatabase', db: 'admin' },
    { role: 'dbAdminAnyDatabase', db: 'admin' }
  ]
});

print('Created opsmanager user successfully');

// Switch to opsmanager database
db = db.getSiblingDB('opsmanager');

// Create basic collections that Ops Manager will need
db.createCollection('organizations');
db.createCollection('projects');
db.createCollection('clusters');
db.createCollection('users');
db.createCollection('alerts');

// Create indexes for better performance
db.organizations.createIndex({ "name": 1 });
db.projects.createIndex({ "orgId": 1, "name": 1 });
db.clusters.createIndex({ "projectId": 1, "name": 1 });
db.users.createIndex({ "emailAddress": 1 });

print('Created collections and indexes successfully');

// Verify the setup
var userCount = db.getSiblingDB('admin').getUsers().length;
print('Total users in admin database: ' + userCount);

var collections = db.getCollectionNames();
print('Collections in opsmanager database: ' + collections.join(', '));

print('MongoDB initialization completed successfully!');

