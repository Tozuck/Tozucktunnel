#!/bin/bash

NETPLAN_DIR="/etc/netplan"
YAML_PREFIX="20-tozuch_techpatogh_tunnel"
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
  # Implementation for set_multi_server
  # ...
}

function show_tunnels() {
  # Implementation for show_tunnels
  # ...
}

function show_ipv6_all() {
  # Implementation for show_ipv6_all
  # ...
}

function ping_tunnel() {
  # Implementation for ping_tunnel
  # ...
}

function ping_tunnel_helper() {
  # Implementation for ping_tunnel_helper
  # ...
}

function delete_all_yaml_files() {
  # Implementation for delete_all_yaml_files
  # ...
}

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
    1) source ./tozuch.sh ;;
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
