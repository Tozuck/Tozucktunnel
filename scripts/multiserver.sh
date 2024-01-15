#!/bin/bash

NETPLAN_DIR="/etc/netplan"
YAML_PREFIX="tozuch_tunnel"
MAX_TUNNELS=10

# Check if terminal supports colors
if [ -t 1 ]; then
    YELLOW=$(tput setaf 3)
    GREEN=$(tput setaf 2)
    RED=$(tput setaf 1)
    CYAN=$(tput setaf 6)
    RESET=$(tput sgr0)
else
    YELLOW=""
    GREEN=""
    RED=""
    CYAN=""
    RESET=""
fi

function set_multi_server() {
    # Ask user for Iran (1) or Kharej (2)
    read -p "${RED}Choose the server (1. Iran or 2. Kharej): ${RESET}" server_type

    case $server_type in
        1) server_name="iran" ;;
        2) server_name="kharej" ;;
        *) echo -e "${RED}Invalid choice. Please enter 1 or 2.${RESET}"; return ;;
    esac

    # Ask user for Iran IPv4 address
    read -p "${RED}Enter the IPv4 address for Iran: ${RESET}" iran_ipv4

    # Ask user for Kharej IPv4 address
    read -p "${RED}Enter the IPv4 address for Kharej: ${RESET}" kharej_ipv4

    # Ask user for tunnel number (1-10)
    read -p "${RED}Enter the tunnel number (1-$MAX_TUNNELS): ${RESET}" tunnel_number

    if ((tunnel_number < 1 || tunnel_number > MAX_TUNNELS)); then
        echo -e "${RED}Invalid tunnel number. Please enter a number between 1 and $MAX_TUNNELS.${RESET}"
        return
    fi

    tunnel_name="tunnel$(printf "%02d" $tunnel_number)"
    yaml_file="$NETPLAN_DIR/$YAML_PREFIX${tunnel_number}_${server_name}.yaml"

    # Determine local and remote based on the server choice
    local_ipv4=$iran_ipv4
    remote_ipv4=$kharej_ipv4

    if [ "$server_name" == "kharej" ]; then
        local_ipv4=$kharej_ipv4
        remote_ipv4=$iran_ipv4
    fi

    # Create netplan configuration file for the tunnel
    sudo tee "$yaml_file" > /dev/null <<EOL
network:
  version: 2
  tunnels:
    $tunnel_name:
      mode: sit
      local: $local_ipv4
      remote: $remote_ipv4
      addresses:
        - 2001:db8:50$(printf "%02d" $tunnel_number)::$(if [ "$server_name" == "iran" ]; then echo "1"; else echo "2"; fi)/64
EOL

    echo -e "${GREEN}IPv6 local for $tunnel_name on $server_name server created successfully.${RESET}"

    # Apply netplan configuration for the tunnel
    sudo netplan apply
}

# Rest of the script remains unchanged

# Multi Server menu
function multi_server() {
    clear
    while true; do
        echo -e "${YELLOW}--- Multi Server Menu ---${RESET}"
        echo -e "${YELLOW}1. Set Multi Server${RESET}"
        echo -e "${YELLOW}2. Show Configured Tunnels${RESET}"
        echo -e "${YELLOW}3. Show IPv6 Addresses for All Tunnels${RESET}"
        echo -e "${YELLOW}4. Ping a Tunnel${RESET}"
        echo -e "${YELLOW}5. Delete All YAML Files${RESET}"
        echo -e "${YELLOW}0. Back to Main Menu${RESET}"

        read -p "Enter your choice (1-5, 0 to go back): " choice

        case $choice in
            1) set_multi_server ;;
            2) show_tunnels ;;
            3) show_ipv6_all ;;
            4) ping_tunnel ;;
            5) delete_all_yaml_files ;;
            0) clear; break ;;
            *) echo -e "${YELLOW}Invalid choice. Please enter a number between 1 and 5, or 0 to go back.${RESET}" ;;
        esac
    done
}

# Main menu
clear
echo -e "${YELLOW}---------------------------${RESET}"
echo -e "${YELLOW}Tunnels by Tozuch & tech_patogh${RESET}"
echo -e "${YELLOW}---------------------------${RESET}"

while true; do
    echo -e "${YELLOW}1. IPv6 Local${RESET}"
    echo -e "${YELLOW}2. Multi Server${RESET}"
    echo -e "${YELLOW}3. System Settings${RESET}"
    echo -e "${YELLOW}0. Exit${RESET}"

    read -p "Enter your choice (1-3, 0 to exit): " choice

    case $choice in
        1) source /path/to/tozuch.sh ;;
        2) multi_server ;;
        3)
            # Sub-menu for System Settings
            while true; do
                clear
                echo -e "${YELLOW}--- System Settings ---${RESET}"
                echo -e "${YELLOW}1. Update${RESET}"
                echo -e "${YELLOW}2. List Netplan directory${RESET}"
                echo -e "${YELLOW}0. Back to Main Menu${RESET}"

                read -p "Enter your choice (1-2, 0 to go back): " sys_choice

                case $sys_choice in
                    1) sudo apt update && echo -e "${GREEN}System updated successfully.${RESET}" ;;
                    2) cd $NETPLAN_DIR && ls && exec $SHELL ;;
                    0) break ;;
                    *) echo -e "${YELLOW}Invalid choice. Please enter 1, 2, or 0.${RESET}" ;;
                esac
            done
            ;;
        0) clear; exit 0 ;;
        *) echo -e "${YELLOW}Invalid choice. Please enter 1, 2, 3, or 0.${RESET}" ;;
    esac
done
