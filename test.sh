#!/usr/bin/env bash

# Define global variables here

# Define required and additional package dependencies
declare -a packages=("unzip" "wget" "curl")

# Define the installation directory
install_dir= $(grep 'INSTALL_DIR' dev.conf | cut -d= -f2)

# Function to handle errors
function handle_error() {
    echo "Error: $1"
    if [ -n "$2" ]; then
        eval "$2"
    fi
    exit 1
}
https://app.codegra.de/courses/5526/enroll/a9baccef-3688-4d06-acf8-9371188f13cf
# Function to solve dependencies
function setup() {
    echo "Setting up..."

    # Check if necessary dependencies and folder structure exist
    for package in "${packages[@]}"; do
        if ! dpkg -l | grep -q "$package"; then
            handle_error "Dependency '$package' is not installed. Please install it." "sudo apt-get install $package"
        else
            echo "Dependency '$package' is installed."
        fi
    done

    if [ ! -d "$install_dir" ]; then
        mkdir -p "$install_dir"
        echo "Created '$install_dir' directory."
    fi

    if [ ! -f "config.conf" ]; then
        touch "config.conf"
        echo "Created 'config.conf' file."
    fi

    if [ -d "$install_dir" ] && [ -f "config.conf" ]; then
        echo "Setup completed successfully."
    else
        handle_error "Setup failed. Please check the required folder and file structure."
    fi
}

# Function to install a package from a URL
function install_package() {
    local package_name="$1"
    local package_url="$2"
    local package_install_dir="$3"
    
    echo "Installing $package_name..."
    if [ -d "$package_install_dir/$package_name" ]; then
        handle_error "$package_name is already installed."
    fi

    if [ -z "$package_url" ]; then
        handle_error "Package URL is not specified in config.conf for $package_name."
    fi

    if [ ! -d "$package_install_dir" ]; then
        mkdir -p "$package_install_dir"
    fi

    if ! wget -q "$package_url" -P "$package_install_dir"; then
        handle_error "Failed to download $package_name from $package_url."
    fi

    if ! unzip -q "$package_install_dir/$(basename "$package_url")" -d "$package_install_dir"; then
        handle_error "Failed to unzip $package_name."
    fi

    # Implement application-specific installation logic if needed
    if [ "$package_name" == "nosecrets" ]; then
        # Add any Nosecrets-specific installation steps here
        echo "Nosecrets-specific installation steps..."
        mv "$package_install_dir/no-more-secrets-master" "$package_install_dir/$package_name"
    elif [ "$package_name" == "pywebserver" ]; then
        # Add any Pywebserver-specific installation steps here
        echo "Pywebserver-specific installation steps..."
        mv "$package_install_dir/webserver-master" "$package_install_dir/$package_name"

    fi
    rm "$package_install_dir/master.zip"
    echo "$package_name is installed."
}

function rollback_nosecrets() {
    echo "Rolling back Nosecrets installation..."
    # Implement rollback logic for Nosecrets if needed
    if [ -d "$install_dir/nosecrets" ]; then
        rm -rf "$install_dir/nosecrets"
    fi
}

function rollback_pywebserver() {
    echo "Rolling back Pywebserver installation..."
    # Implement rollback logic for Pywebserver if needed
    if [ -d "$install_dir/pywebserver" ]; then
        rm -rf "$install_dir/pywebserver"
    fi
}

function test_nosecrets() {
    echo "Testing Nosecrets..."
    # Implement tests for Nosecrets if needed
    if [ -d "$install_dir/nosecrets" ]; then
        # Add Nosecrets-specific test steps here
        echo "Nosecrets-specific test steps..."
    else
        handle_error "Nosecrets is not installed."
    fi
}

function test_pywebserver() {
    echo "Testing Pywebserver..."
    # Implement tests for Pywebserver if needed
    if [ -d "$install_dir/pywebserver" ]; then
        # Add Pywebserver-specific test steps here
        echo "Pywebserver-specific test steps..."
    else
        handle_error "Pywebserver is not installed."
    fi
}

function uninstall_nosecrets() {
    echo "Uninstalling Nosecrets..."
    # Implement uninstallation logic for Nosecrets if needed
    rollback_nosecrets
    echo "Nosecrets is uninstalled."
}

function uninstall_pywebserver() {
    echo "Uninstalling Pywebserver..."
    # Implement uninstallation logic for Pywebserver if needed
    rollback_pywebserver
    echo "Pywebserver is uninstalled."
}

# Function to remove installed dependencies during setup and restore the folder structure to the original state
function remove() {
    echo "Removing installed dependencies..."

    if [ -d "$install_dir" ]; then
        rm -rf "$install_dir"
    fi

    if [ -f "config.conf" ]; then
        rm "config.conf"
    fi

    echo "Dependencies are removed, and the folder structure is restored."
}

function main() {
    echo "Main function..."
    echo "Created '$(grep 'INSTALL_DIR' dev.conf | cut -d= -f2)' directory."
    echo "Created '$install_dir' directory."


    # Read global variables from config file if needed


    # Check if the first argument is valid
    case "$1" in
        "setup"|"nosecrets"|"pywebserver"|"remove") ;;
        *)
            handle_error "Invalid command: $1"
            ;;
    esac

    # # Get arguments from the command line
    # if [ $# -lt 2 ]; then
    #     handle_error "Insufficient arguments provided. Usage: ./assignment.sh [setup|nosecrets|pywebserver|remove] [--install|--uninstall|--test]"
    # fi
    # # Check if the second argument is provided on the command line
    # if [ -z "$2" ]; then
    #     handle_error "Missing second argument. Usage: ./assignment.sh [setup|nosecrets|pywebserver|remove] [--install|--uninstall|--test]"
    # fi

    # Check if the second argument is valid
    case "$2" in
        "--install"|"--uninstall"|"--test") ;;
        *)
            handle_error "Invalid option: $2"
            ;;
    esac

    # Execute the appropriate command based on the arguments
    case "$1" in
        "setup")
            setup
            ;;
        "nosecrets")
            if [ "$2" == "--install" ]; then
                install_package "nosecrets" "$(grep 'APP1_URL' dev.conf | cut -d= -f2)" "$install_dir"
            elif [ "$2" == "--uninstall" ]; then
                uninstall_nosecrets
            elif [ "$2" == "--test" ]; then
                test_nosecrets
            fi
            ;;
        "pywebserver")
            if [ "$2" == "--install" ]; then
                install_package "pywebserver" "$(grep 'APP2_URL' dev.conf | cut -d= -f2)" "$install_dir"
            elif [ "$2" == "--uninstall" ]; then
                uninstall_pywebserver
            elif [ "$2" == "--test" ]; then
                test_pywebserver
            fi
            ;;
        "remove")
            remove
            ;;
    esac
}

# Pass command-line arguments to function main
main "$@"