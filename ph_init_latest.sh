#!/bin/bash

# Exit on any error
set -e

# Function to check if PostgreSQL source file exists
check_postgres_source() {
    if ! ls postgresql*.tar.gz >/dev/null 2>&1; then
        echo "Error: PostgreSQL source file (postgresql*.tar.gz) not found in current directory"
        exit 1
    fi
}

# Function to validate user creation
validate_user() {
    local username=$1
    if id "$username" >/dev/null 2>&1; then
        echo "Notice: User $username already exists"
        return 0
    fi
    return 1
}

# Main installation script
main() {
    # Check for root privileges
    if [ "$EUID" -ne 0 ]; then
        echo "Please run as root"
        exit 1
    fi

    # Verify PostgreSQL source exists
    check_postgres_source

    # Get PostgreSQL source filename
    DN=$(ls postgresql*.tar.gz)
    echo "Found PostgreSQL source: $DN"

    # Extract source
    tar -xzf "$DN"
    
    # Get directory name after extraction
    CDN=$(ls -d postgresql-*/ | head -n 1 | sed 's/\/$//')
    CD1=$(echo "$CDN" | grep -oP '\d+\.\d+' | head -n 1)
    
    if [ -z "$CDN" ] || [ -z "$CD1" ]; then
        echo "Error: Could not determine PostgreSQL version"
        exit 1
    fi

    # User creation
    read -p "Enter username: " username
    read -s -p "Enter password: " password
    echo

    if ! validate_user "$username"; then
        useradd -m "$username"
        echo "$username:$password" | chpasswd
    fi

    # Create installation directory
    PGSQL_BASE="/usr/local/pgsql/$CD1"
    mkdir -p "$PGSQL_BASE"

    # Install dependencies
    echo "Installing dependencies..."
    yum install -y gcc flex bison readline-devel zlib-devel make cmake
    yum install -y gcc-c++ sqlite-devel libtiff-devel libcurl-devel libxml2-devel

    # Compile and install PostgreSQL
    echo "Compiling PostgreSQL..."
    cd "$CDN"
    ./configure --prefix="$PGSQL_BASE"
    make world
    make install-world

    # Initialize database
    echo "Initializing database..."
    mkdir -p "$PGSQL_BASE/data"
    chown -R postgres. "$PGSQL_BASE/data"
    
    # Initialize and start PostgreSQL
    su - postgres -c "$PGSQL_BASE/bin/initdb -D $PGSQL_BASE/data"
    su - postgres -c "$PGSQL_BASE/bin/pg_ctl -D $PGSQL_BASE/data -l $PGSQL_BASE/logfile start"
    
    # Check status
    sleep 5
    su - postgres -c "$PGSQL_BASE/bin/pg_ctl -D $PGSQL_BASE/data status"
    
    echo "PostgreSQL installation completed"
}

# Run the main function
main
