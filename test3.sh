#!/usr/bin/env bash

# TODO: Add required and additional package dependencies
declare -a packages=("unzip" "wget" "curl")

# TODO: define a function to handle errors
# This function accepts two parameters: an error message and a command to be executed when an error occurs.
function handle_error() {

    echo "function handle_error"
  
    echo "Error: $1"
    if [ ! -z "$2" ]; then
        eval "$2"
    fi
    exit 1
}

# Function to solve dependencies
function setup() {
    echo "Setting up..."

    # Check if necessary dependencies and folder structure exist
    for package in "${packages[@]}"; do
        if ! command -v "$package" &>/dev/null; then
            handle_error "$package is not installed. Please install it before proceeding." "sudo apt-get install $package"
        fi
    done

    # Check if required folders and files exist before installations
    if [ ! -d "$(grep 'INSTALL_DIR' dev.conf | cut -d= -f2)" ]; then
        mkdir -p "$(grep 'INSTALL_DIR' dev.conf | cut -d= -f2)"
    fi
}

# Function to install a package from a URL
function install_package() {
    local package_name="$1"
    local package_url="$2"
    local install_dir="$3"
    
    echo "Installing $package_name..."

    # Check if the application folder and the URL of the dependency exist
    if [ ! -d "$install_dir/$package_name" ]; then
        mkdir -p "$install_dir/$package_name"
    fi

    # Download and unzip the package
    wget -O "$install_dir/$package_name.zip" "$package_url"
    if [ $? -ne 0 ]; then
        handle_error "Failed to download $package_name." "rm -rf $install_dir/$package_name"
    fi
    unzip "$install_dir/$package_name.zip" -d "$install_dir"
    if [ $? -ne 0 ]; then
        handle_error "Failed to unzip $package_name." "rm -rf $install_dir"
    fi

    # Implement application-specific logic here
    if [ "$package_name" == "nosecrets" ]; then
        # Add any Nosecrets-specific installation steps here
        echo "Nosecrets-specific installation steps... "
        mv -T "$install_dir/no-more-secrets-master" "$install_dir/$package_name"
    elif [ "$package_name" == "pywebserver" ]; then
        # Add any Pywebserver-specific installation steps here
        echo "Pywebserver-specific installation steps..."
        mv -T "$install_dir/webserver-master" "$install_dir/$package_name"

    fi
    # cleanup install zip
    rm "$install_dir/$package_name.zip"
    echo "$package_name has been installed successfully."
}

# Function to uninstall a package
function uninstall_package() {
    local package_name="$1"
    local install_dir="$2"

    echo "Uninstalling $package_name..."

    if [ -d "$install_dir/$package_name" ]; then
        rm -rf "$install_dir/$package_name"
        echo "$package_name has been uninstalled."
    else
        echo "$package_name is not installed."
    fi
}

# Function to test a package installation
function test_package() {
    local package_name="$1"
    echo "Testing $package_name..."

    # Implement the test logic for the package here

    echo "$package_name has been tested successfully."
}

# Function to handle rollback for package installation
function rollback_package() {
    local package_name="$1"
    echo "Rolling back $package_name installation..."
    # Implement the rollback logic for package installation here
    echo "$package_name installation has been rolled back."
}

# Function to handle the main logic of the script
function main() {
    # Read global variables from configfile
    source config.conf

    # Get arguments from the command line
    local command="$1"
    local action="$2"

    if [ -z "$command" ]; then
        handle_error "Missing command. Usage: $0 <command> [package] [action]"
    fi

    case "$command" in
        "setup")
            setup
            ;;
        "nosecrets")
            case "$action" in
                "--install")
                    install_package "nosecrets" "$(grep 'APP1_URL' dev.conf | cut -d= -f2)" "$(grep 'INSTALL_DIR' dev.conf | cut -d= -f2)"
                    ;;
                "--uninstall")
                    uninstall_package "nosecrets" "$(grep 'INSTALL_DIR' dev.conf | cut -d= -f2)"
                    ;;
                "--test")
                    test_package "nosecrets"
                    ;;
                *)
                    handle_error "Invalid action for nosecrets. Use --install, --uninstall, or --test."
                    ;;
            esac
            ;;
        "pywebserver")
            case "$action" in
                "--install")
                    install_package "pywebserver" "$(grep 'APP2_URL' dev.conf | cut -d= -f2)" "$(grep 'INSTALL_DIR' dev.conf | cut -d= -f2)"
                    ;;
                "--uninstall")
                    uninstall_package "pywebserver" "$(grep 'INSTALL_DIR' dev.conf | cut -d= -f2)"
                    ;;
                "--test")
                    test_package "pywebserver"
                    ;;
                *)
                    handle_error "Invalid action for pywebserver. Use --install, --uninstall, or --test."
                    ;;
            esac
            ;;
        *)
        handle_error "Invalid package name. Use 'nosecrets' or 'pywebserver'."
        ;;
    esac
}

# Pass command-line arguments to function main
main "$@"