lighty
======

(c) 2008 Jason Frame (<jason@onehackoranother.com>)<br/>
Released under The MIT License.

Synopsis
--------

As a Rails user spoiled by the utility of `script/server`, I wince whenever I need to start a new PHP project - a process invariably requiring one of the following courses of action:

 1. Create a new Apache vhost. An absolute pain in the bottom. Needs to be
    repeated on every dev system.
 2. Develop in `~/public_html`. Lame - now my app needs to support being run from
    subdirectories and I can't check the project out into my normal working directory
    hierarchy unless I also enable `FollowSymLinks`.
     
And let's not forget about different PHP versions - you might want to test your app against the latest stable version, try out the new features in 5.3, or run a legacy app on 4.x. Have fun doing that with Apache.

`lighty` was created to address these problems and supports:
  
 * Spontaneous development - change to any directory, type `lighty` and
   Bob's your Dad's brother.
 * Concise command line options for configuring common use cases such as
   setting the document root or routing all 404s to a single "dispatch" URL.
 * Multiple PHP versions with indirect referencing - configure available
   version numbers and binaries once on a system-wide basis and refer to
   them thereafter by version number alone - great for teams or single
   developers with multiple systems as your per-app configuration need not
   contain the path to the PHP binary.
 * Hierarchical configuration - options can be specified in global and local
   config files, and via the command line, with each source being more
   specific (and hence overriding) its predecessor.
  
Requirements
------------

 * lighttpd
 * Ruby & rubygems
 * FastCGI binaries for any versions of PHP you wish to run
  
Installation
------------

    sudo gem install jaz303-lighty

Configuration
-------------

After installing, run `lighty` from the console. This may or not break depending on whether the default path to the lighttpd binary is correct for your system. In either case, a couple of config files will be created in `~/.lighty`:

 * `config.yml` specifies the defaults `lighty` will use when generating a config
   file and is well documented. Any number of defaults may be overridden by placing
   them in a file named `.lighty.yml` within the directory from which `lighty` is
   invoked, or by passing options on the commmand line.
 * `lighty.conf.erb` is a skeleton config file for lighttpd; edit this to your
   liking, taking care not to munge the ERb sections.
   
Simple Examples
---------------

Serve files from the current directory and use the default configuration for all other settings:

    lighty

Serve files from the current directory, listen on port 4000 and enable directory listings:

    lighty -p 4000 --directory-listing

Serve files from `./public`, enable the default PHP version and route all 404s to `/_dispatch.php`:

    lighty -r public --php -d /_dispatch.php

Serve files from the current directory, enable PHP version 5.3.0:

    lighty --php 5_3_0

Disable PHP and directory listings (only necessary if previously enabled by config file):

    lighty --php false --directory-listing false
    
A More Complex Example
----------------------

Let's imagine we're developing yet another PHP-based CMS. We're actively using a couple of versions of PHP, but don't want either enabled by default. Here's the relevant section from the global config (`~/.lighty/config.yml`):

    php:
      enabled: false
      versions:
        5_2_8: "/path/to/php/5_2_8"
        5_3_0: "/path/to/php/5_3_0"


The CMS project's document root is the directory `public`, and in order to implement SEO-friendly URLs the system requires that all 404s be dispatched to `/_dispatch.php`. We also need to enable PHP. Because this configuration is specific to the project, we'll place the following in the local config file `.lighty.yml` within the CMS project root:

    php:
      enabled: true
    dispatcher: "/_dispatch.php"
    document_root: "public"

We can now change project directory and run `lighty` to get a freshly configured server to taste. The global and local settings will be merged, with the local settings taking precedence. Because we haven't specified a default PHP version in either file, `lighty` will select the best available version (5.3.0). This can be overridden (as can any other option) on the command-line, e.g. `lighty --php 5_2_8`.

When it comes to sharing this project with others, check the local `lighty` config file into the project's VCS. Because the local configuration file contains no system-specific configuration, other developers will be able to run `lighty` without modification (assuming they have a compatible global configuration).
