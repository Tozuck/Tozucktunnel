#!/bin/bash

# ANSI color codes
YELLOW='\033[1;33m'
NC='\033[0m'  # No color

# Check the operating system
if [ "$(lsb_release -si)" != "Ubuntu" ]; then
    echo -e "${YELLOW}This script is intended for Ubuntu only.${NC}"
    exit 1
fi

# Display a welcome banner
echo -e "${YELLOW}Welcome to Tozuck Tunnel Script${NC}"

while true; do
    # Clear the screen
    clear

    echo -e "${YELLOW}Menu:${NC}"
    echo -e "${YELLOW}1.${NC} Set solo tunnel"
    echo -e "${YELLOW}2.${NC} Set multi-server tunnel"
    echo -e "${YELLOW}3.${NC} DNS changer"
    echo -e "${YELLOW}4.${NC} System update"
    echo -e "${YELLOW}0.${NC} Exit"

    read -p "Enter your choice: " choice

    case $choice in
        1)
            # Clear the screen
            clear

            echo "Setting solo tunnel..."
            
            # Ask for the server type
            echo "Select the server type:"
            echo "1. Iran"
            echo "2. Kharej"
            read -p "Enter your choice: " server_choice

            if [ "$server_choice" == "1" ]; then
                read -p "Enter Iran IPv4 address: " iran_ipv4
                read -p "Enter Kharej IPv4 address: " kharej_ipv4
                
                # Create the netplan configuration file
                cat <<EOF | sudo tee /etc/netplan/tozucksolotunel.yaml
network:
  version: 2
  tunnels:
    solotunel:
      mode: sit
      local: $iran_ipv4
      remote: $kharej_ipv4
      addresses:
        - 2001:db8:400::1/64
EOF
                
                # Apply the netplan configuration
                sudo netplan apply

                echo "Solo tunnel configuration applied."
            elif [ "$server_choice" == "2" ]; then
                read -p "Enter Iran IPv4 address: " iran_ipv4
                read -p "Enter Kharej IPv4 address: " kharej_ipv4
                
                # Create the netplan configuration file
                cat <<EOF | sudo tee /etc/netplan/tozucksolotunel.yaml
network:
  version: 2
  tunnels:
    solotunel:
      mode: sit
      local: $kharej_ipv4
      remote: $iran_ipv4
      addresses:
        - 2001:db8:400::2/64
EOF
                
                # Apply the netplan configuration
                sudo netplan apply

                echo "Solo tunnel configuration applied."
            else
                echo "Invalid choice. Please enter a valid option."
            fi
            ;;
        2)
            # Clear the screen
            clear

            echo "Setting multi-server tunnel..."
            bash scripts/multiserver.sh
            ;;
        3)
            # Clear the screen
            clear

            echo "Changing DNS..."
            bash scripts/dns.sh
            ;;
        4)
            # Clear the screen
            clear

            echo "Updating system..."
            sudo apt update
            ;;
        0)
            echo "Exiting..."
            cd
            exit 0
            ;;
        *)
            echo -e "${YELLOW}Invalid choice. Please enter a valid option.${NC}"
            ;;
    esac

    # Add a line break for better readability
    echo
    read -n 1 -s -r -p "Press any key to continue..."
done
