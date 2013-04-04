<?php

// PRISM
// By viveleroi.
// discover-prism.com
require_once('libs/Peregrine.php');
require_once('libs/Auth.php');
require_once('libs/Prism.php');
define('WEB_UI_VERSION', 'nightly');
define('WEB_UI_DEBUG', false);


// REMEMBER: Rename this file to "config.php".


// ------------------------------------------
// DATABASE
// ------------------------------------------

// Setup your MySQL connection information
// below.

define("MYSQL_HOSTNAME", "127.0.0.1");
define("MYSQL_USERNAME", "root");
define("MYSQL_PASSWORD", "");
define("MYSQL_DATABASE", "minecraft");
define("MYSQL_PORT", 3306);


// ------------------------------------------
// TIMEZONE
// ------------------------------------------

// For date calculations, php needs you to set a timezone if you haven't
// by default (in php.ini). Please make sure it's the same timezone
// that your MySQL is set to use, so that dates will be equal
// when using the timeframe field.

// List of supported timezones:
// http://php.net/manual/en/timezones.php
date_default_timezone_set('America/Los_Angeles');


// NOTICE:
//
// We *strongly* recommend that you use a mysql account that has been given
// SELECT permissions ONLY. We try to ensure that this web interface can't be
// used maliciously but the more safeguards you can take, the better.

// This interface does not yet support sqlite databases.

// ------------------------------------------
// USER AUTHENTICATION
// ------------------------------------------

// This is a basic method for requiring user authentication
// before being allowed to access the interface.

// You can add as many users as you wish by following the instructions
// below.

// Change this to "true" if you want to require authentication
define("REQUIRE_AUTH", false);

$auth = new Auth();

// Define usernames and passwords below, in the format of
// $auth->addUser( "username", "password" );

$auth->addUser( "admin", "prism" );


// ------------------------------------------
// OVERRIDE THE AUTHENTICATION
// ------------------------------------------

// It's very easy to write a custom class to authenticate
// users using your own system

// Simple review the example-auth/CustomAuth.php file for
// directions, and then be sure to include your custom
// file here:

// include('example-auth/CustomAuth.php');