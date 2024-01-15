#!/bin/bash

NETPLAN_DIR="/etc/netplan"
YAML_FILE="$NETPLAN_DIR/tozucksolotunnel.yaml"  # Updated YAML file name

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

# ... (previous functions remain unchanged)

function dns_changer_menu() {
  while true; do
    clear
    echo -e "${YELLOW}--- DNS Changer Menu ---${RESET}"
    echo -e "${YELLOW}1. Change DNS Settings${RESET}"
    echo -e "${YELLOW}2. Show Current DNS Settings${RESET}"
    echo -e "${YELLOW}0. Back to Main Menu${RESET}"

    read -p "Enter your choice (1-2, 0 to go back): " dns_choice

    case $dns_choice in
      1) change_dns_settings ;;
      2) show_current_dns_settings ;;
      0) break ;;
      *) echo -e "${YELLOW}Invalid choice. Please enter 1, 2, or 0.${RESET}" ;;
    esac
  done
}

function change_dns_settings() {
  # Add your logic here to change DNS settings
  echo -e "${YELLOW}Change DNS settings logic goes here.${RESET}"
  # You might want to call an external script like /scripts/dns.sh here
  # Example: /bin/bash /scripts/dns.sh
  # Ensure the script /scripts/dns.sh exists and is executable
}

function show_current_dns_settings() {
  # Add your logic here to show current DNS settings
  echo -e "${YELLOW}Show current DNS settings logic goes here.${RESET}"
  # You might want to call an external script like /scripts/dns.sh here
  # Example: /bin/bash /scripts/dns.sh show
  # Ensure the script /scripts/dns.sh exists and is executable
}

function set_ip6_local() {
  # ... (rest of the set_ip6_local function remains unchanged)
}

function ping_ip6_iran() {
  # ... (rest of the ping_ip6_iran function remains unchanged)
}

function ping_ip6_kharej() {
  # ... (rest of the ping_ip6_kharej function remains unchanged)
}

function show_ipv6() {
  # ... (rest of the show_ipv6 function remains unchanged)
}

function uninstall_and_delete_all_files() {
  # ... (rest of the uninstall_and_delete_all_files function remains unchanged)
}

function _server() {
  # ... (rest of the _server function remains unchanged)
}

function ipv6_local_menu() {
  # ... (rest of the ipv6_local_menu function remains unchanged)
}

# Main menu
while true; do
  echo -e "${YELLOW}1. IPv6 Local${RESET}"
  echo -e "${YELLOW}2. Multi Server${RESET}"
  echo -e "${YELLOW}3. DNS Changer${RESET}"  # New menu option for DNS changer
  echo -e "${YELLOW}4. System Settings${RESET}"
  echo -e "${YELLOW}0. Exit${RESET}"

  read -p "Enter your choice (1-4, 0 to exit): " choice

  case $choice in
    1) ipv6_local_menu ;;
    2) _server ;;
    3) dns_changer_menu ;;  # New menu option for DNS changer
    4)
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
    *) echo -e "${YELLOW}Invalid choice. Please enter 1, 2, 3, 4, or 0.${RESET}" ;;
  esac
done

