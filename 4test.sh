#!/usr/bin/env bash

# Define global variable here

# Add required and additional package dependencies
declare -a packages=("unzip" "wget" "curl")

#  define a function to handle errors
# This function accepts two parameters: an error message and a command to be executed when an error occurs.
function handle_error() {
    # Do not remove next line!
    echo "function handle_error"
    
    echo "Error: $1"
    if [ ! -z "$2" ]; then
        eval "$2"
    fi
    exit 1
}

# Function to solve dependencies
function setup() {
    # Do not remove next line!
    echo "function setup"

    # TODO: Check if necessary dependencies and folder structure exist



    # TODO installation from online package requires values for package_name package_url install_dir



    # TODO installation from online package requires values for
    # package_name package_url install_dir

    # check if required dependency is not already installed otherwise install it
    # if a a problem occur during the this process 
    # use the function handle_error() to print a messgage and handle the error
     for package in "${packages[@]}"; do
        if ! command -v "$package" &>/dev/null; then
            echo "$package is not installed. Installing it..."
            sudo apt-get install "$package" || handle_error "Failed to install $package." "apt-get install $package"
        fi
        echo "Dependency '$package' is installed."
    done

    #  Check if required folders and files exist before installations
    # check if ./apps/ exists
    if [ ! -d "$INSTALL_DIR" ]; then
        mkdir -p "$INSTALL_DIR"
    fi
    # check dev.conf
    if [ -f "dev.conf" ]; then
        echo "dev.conf bestaat."
    else
        echo "dev.conf bestaat niet."
    fi
}

# Function to install a package from a URL
function install_package() {
    # Do not remove next line!
    echo "function install_package"
    local package_name="$1"
    local package_url="$2"
    local install_dir="$3"
    
    echo "Installing $package_name..."

    # TODO: Check if the application folder and the URL of the dependency exist
    # folder
    if [ ! -d "$install_dir/$package_name" ]; then
        mkdir -p "$install_dir/$package_name"
    fi
    # make temp folder 
    mkdir -p "$install_dir/tmp"


    #  URL of the dependency exists
    if curl --output /dev/null --silent --head --fail "$package_url"; then
        echo "URL for $package_name exists."
    else
        handle_error "URL for $package_name does not exist."
    fi


    # TODO: Download and unzip the package
    wget -O "$install_dir/temp/$package_name.zip" "$package_url"
    if [ $? -ne 0 ]; then
        handle_error "Failed to download $package_name." "rm -rf $install_dir/temp/$package_name"
    fi
    unzip "$install_dir/temp/$package_name.zip" -d "$install_dir/temp/$package_name"
    if [ $? -ne 0 ]; then
        handle_error "Failed to unzip $package_name." "rm -rf $install_dir/temp/$package_name"
    fi

    # TODO: Implement application-specific logic here
    if [ "$package_name" == "nosecrets" ]; then
        # Add any Nosecrets-specific installation steps here
        echo "Nosecrets-specific installation steps... "
        mv -T "$install_dir/temp/no-more-secrets-master" "$install_dir/$package_name"
    elif [ "$package_name" == "pywebserver" ]; then
        # Add any Pywebserver-specific installation steps here
        echo "Pywebserver-specific installation steps..."
        mv -T "$install_dir/webserver-master" "$install_dir/$package_name"
    fi

    # cleanup install temp folder
    rm "$install_dir/temp"

    echo "$package_name has been installed successfully."
}

function rollback_nosecrets() {
    # Do not remove next line!
    echo "function rollback_nosecrets"

    # TODO rollback intermiediate steps when installation fails
}

function rollback_pywebserver() {
    # Do not remove next line!
    echo "function rollback_pywebserver"

    # TODO rollback intermiediate steps when installation fails
}

function test_nosecrets() {
    # Do not remove next line!
    echo "function test_nosecrets"

    # TODO test nosecrets
    # kill this webserver process after it has finished its job

}

function test_pywebserver() {
    # Do not remove next line!
    echo "function test_pywebserver"    

    # TODO test the webserver
    # server and port number must be extracted from config.conf
    # test data must be read from test.json  
    # kill this webserver process after it has finished its job

}

function uninstall_nosecrets() {
    # Do not remove next line!
    echo "function uninstall_nosecrets"  

    #task: uninstall nosecrets application
    # fix: remove folder nosecrets
    rm "$install_dir/nosecrets"

}

function uninstall_pywebserver() {
    echo "function uninstall_pywebserver"    
    
    #task: uninstall pywebserver application
    # fix: remove folder nosecrets
    rm "$install_dir/pywebserver"
}

#TODO removing installed dependency during setup() and restoring the folder structure to original state
function remove() {
    # Do not remove next line!
    echo "function remove"

    # task: Remove each package that was installed during setup
    # fix: remove the install folder and make a new install folder 

    rm "$install_dir"

    mkdir -p "$install_dir"
}

function main() {
    # Do not remove next line!
    echo "function main"
    # Read global variables from configfile
    source dev.conf

    # Get arguments from the command line
    local command="$1"
    local package_name="$2"

    if [ -z "$command" ]; then
        handle_error "Missing command. Usage: $0 <command> [package]"
    fi

    case "$command" in
        "setup")
            setup
            ;;
        "nosecrets")
            case "$action" in
                "--install")
                    install_package "nosecrets" "$APP1_URL" "$INSTALL_DIR"
                    ;;
                "--uninstall")
                    uninstall_nosecrets
                    ;;
                "--test")
                    test_nosecrets
                    ;;
                *)
                    handle_error "Invalid action for nosecrets. Use --install, --uninstall, or --test."
                    ;;
            esac
            ;;
        "pywebserver")
            case "$action" in
                "--install")
                    install_package "pywebserver" "$APP2_URL" "$INSTALL_DIR"
                    ;;
                "--uninstall")
                    uninstall_pywebserver
                    ;;
                "--test")
                    test_pywebserver "pywebserver"
                    ;;
                *)
                    handle_error "Invalid action for pywebserver. Use --install, --uninstall, or --test."
                    ;;
            esac
            ;;
             "remove")
            remove
            ;;
        *)
            handle_error "allowed values are setup, nosecrets, pywebserver and remove"
            ;;
    esac
}

# Pass command-line arguments to function main
main "$@"