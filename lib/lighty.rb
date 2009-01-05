$:.unshift(File.dirname(__FILE__))

require 'yaml'
require 'fileutils'
require 'optparse'
require 'erb'

require 'lighty/core_ext'
require 'lighty/version'
require 'lighty/config'
require 'lighty/app'
