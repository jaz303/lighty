lighty
======

(c) 2008 Jason Frame (<jason@onehackoranother.com>)<br/>
Released under The MIT License.

Synopsis
--------

`lighty`

Installation
------------

    sudo gem install jaz303-lighty

Configuration
-------------

After installing, run `lighty` from the console. This may or not break depending on whether the default path to the lighttpd is correct for your system. In either case, a couple of config files will be created in `~/.lighty`:

 * `config.yml` specifies the defaults `lighty` will use when generating a config
   file and is well documented. Any number of defaults may be overridden by placing
   them in a file named `.lighty.yml` within the directory from which `lighty` is
   invoked, or by passing options on the commmand line.
 * `lighty.conf.erb` is a skeleton config file for lighttpd; edit this to your
   liking, taking care not to munge the ERb sections.
   
Examples
--------

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