#!/bin/bash

# Download and install WordPress
wet https://wordpress.org/latest.tar-gz-P /tmp
tar -xzf /tmp/latest.tar.gz -C /var/www/html/

# Additional setup steps if needed

# Clean up temporary files
rm /tmp/latest.tar.gz