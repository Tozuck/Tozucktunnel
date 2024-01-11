#!/bin/bash

NETPLAN_DIR="/etc/netplan"
YAML_FILE="$NETPLAN_DIR/20-tozuch_techpatogh.yaml"

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

function set_ip6_local() {
  # Check if the OS is Ubuntu
  if [ "$(lsb_release -si)" != "Ubuntu" ]; then
    echo -e "${RED}Please use this on Ubuntu.${RESET}"
    return
  fi

  # Install netplan if not installed
  if ! command -v netplan &> /dev/null; then
    sudo apt install -y netplan
  fi

  # Remove existing YAML file
  [ -e "$YAML_FILE" ] && sudo rm -f "$YAML_FILE"

  # Ask user for "iran" and "kharej" IPv4 addresses
  read -p "${RED}Enter the 'iran' IPv4 address: ${RESET}" iran_ipv4
  read -p "${RED}Enter the 'kharej' IPv4 address: ${RESET}" kharej_ipv4

  # Ask user to choose between "iran" and "kharej"
  read -p "${RED}What is this server? (1.iran or 2.kharej): ${RESET}" server_type

  case $server_type in
    1)
      # Create netplan configuration file for "iran" server
      sudo tee "$YAML_FILE" > /dev/null <<EOL
network:
  version: 2
  tunnels:
    solotunnel:
      mode: sit
      local: $iran_ipv4
      remote: $kharej_ipv4
      addresses:
        - 2001:db8:400::1/64
EOL
      ;;
    2)
      # Create netplan configuration file for "kharej" server
      sudo tee "$YAML_FILE" > /dev/null <<EOL
network:
  version: 2
  tunnels:
    solotunnel:
      mode: sit
      local: $kharej_ipv4
      remote: $iran_ipv4
      addresses:
        - 2001:db8:400::2/64
EOL
      ;;
    *)
      echo -e "${RED}Invalid choice. Please enter 1 or 2.${RESET}"
      return
      ;;
  esac

  # Apply netplan configuration
  sudo netplan apply

  echo -e "${GREEN}IPv6 local created successfully.${RESET}"
}

function ping_ip6_iran() {
  clear
  echo -e "${YELLOW}Waiting for 10 pings...${RESET}"
  if ping6 -c 10 2001:db8:400::1; then
    clear
    echo -e "${YELLOW}It's OK!${RESET}"
  else
    echo -e "${YELLOW}We have a problem.${RESET}"
    read -p "Press Enter to restart the script, or press 'q' to exit: " input
    if [ "$input" == "q" ]; then
      clear
      exit 0
    fi
  fi
}

function ping_ip6_kharej() {
  clear
  echo -e "${YELLOW}Waiting for 10 pings...${RESET}"
  if ping6 -c 10 2001:db8:400::2; then
    clear
    echo -e "${YELLOW}It's OK!${RESET}"
  else
    echo -e "${YELLOW}We have a problem.${RESET}"
    read -p "Press Enter to restart the script, or press 'q' to exit: " input
    if [ "$input" == "q" ]; then
      clear
      exit 0
    fi
  fi
}

function show_ipv6() {
  clear
  echo -e "${YELLOW}IPv6 Address for 'iran': ${CYAN}2001:db8:400::1${RESET}"
  echo -e "${YELLOW}IPv6 Address for 'kharej': ${CYAN}2001:db8:400::2${RESET}"
  exit 0
}

function uninstall_and_delete_all_files() {
  [ -e "$YAML_FILE" ] && sudo rm -f "$YAML_FILE"
  sudo netplan apply
  echo -e "${RED}Uninstall and delete all files completed.${RESET}"
  echo -e "${GREEN}Please consider rebooting for complete removal.${RESET}"
  exit 0
}

function _server() {
  # Download multiserver.sh script
  curl -s https://raw.githubusercontent.com/Tozuck/ipv6/main/scripts/multiserver.sh -o multiserver.sh

  # Check if the download was successful
  if [ $? -eq 0 ]; then
    # Execute multiserver.sh
    sleep 2
    bash multiserver.sh

    # Clean up, remove the downloaded script
    rm multiserver.sh
  else
    echo -e "${RED}Failed to download multiserver.sh.${RESET}"
  fi
}


# IPv6 Local menu
function ipv6_local_menu() {
  clear
  while true; do
    echo -e "${YELLOW}--- IPv6 Local Menu ---${RESET}"
    echo -e "${YELLOW}1. Set IPv6 local${RESET}"
    echo -e "${YELLOW}2. Ping IPv6 iran${RESET}"
    echo -e "${YELLOW}3. Ping IPv6 kharej${RESET}"
    echo -e "${YELLOW}4. Show IPv6${RESET}"
    echo -e "${YELLOW}5. Uninstall and Delete All Files${RESET}"
    echo -e "${YELLOW}0. Back to Main Menu${RESET}"

    read -p "Enter your choice (1-5, 0 to go back): " choice

    case $choice in
      1) set_ip6_local ;;
      2) ping_ip6_iran ;;
      3) ping_ip6_kharej ;;
      4) show_ipv6 ;;
      5) uninstall_and_delete_all_files ;;
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
    1) ipv6_local_menu ;;
    2) _server ;;  # Corrected the function name here
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
