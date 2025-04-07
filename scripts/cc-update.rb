#!/usr/bin/env ruby
# frozen_string_literal: true

# 6/7 Coding Challenge - Update Script
# Updates all challenge scripts to the latest version

# This script is a wrapper for the installer with the --update flag

# Constants
HOME_DIR = ENV['HOME']
BIN_DIR = File.join(HOME_DIR, 'bin')
INSTALLER_PATH = File.join(BIN_DIR, 'cc-installer.rb')

# Check if installer exists
unless File.exist?(INSTALLER_PATH)
  puts "Error: Installer script not found at #{INSTALLER_PATH}"
  puts "Please make sure the installer is properly set up."
  exit 1
end

# Build command with any passed arguments
args = ARGV + ['--update']
command = "ruby #{INSTALLER_PATH} #{args.join(' ')}"

# Run the installer with update flag
puts "Running update: #{command}"
exec command
