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
  # Ask user for the number of tunnels (up to a maximum of 10)
  read -p "${RED}How many tunnels do you need? (Max $MAX_TUNNELS): ${RESET}" num_tunnels

  if ((num_tunnels < 1 || num_tunnels > MAX_TUNNELS)); then
    echo -e "${RED}Invalid number of tunnels. Please enter a number between 1 and $MAX_TUNNELS.${RESET}"
    return
  fi

  for ((i = 1; i <= num_tunnels; i++)); do
    tunnel_name="tunnel$(printf "%02d" $i)"
    yaml_file="$NETPLAN_DIR/$YAML_PREFIX$i.yaml"

    # Ask user for local and remote IPv4 addresses for each tunnel
    read -p "${RED}Enter the local IPv4 address for $tunnel_name: ${RESET}" local_ip
    read -p "${RED}Enter the remote IPv4 address for $tunnel_name: ${RESET}" remote_ip

    # Ask user to choose between "Iran" and "Kharej" server
    read -p "${RED}What is this server? (1. Iran or 2. Kharej): ${RESET}" server_type

    case $server_type in
      1) server_name="iran" ;;
      2) server_name="kharej" ;;
      *) echo -e "${RED}Invalid choice. Please enter 1 or 2.${RESET}" ;;
    esac

    # Create netplan configuration file for the tunnel
    sudo tee "$yaml_file" > /dev/null <<EOL
network:
  version: 2
  tunnels:
    $tunnel_name:
      mode: sit
      local: $local_ip
      remote: $remote_ip
      addresses:
        - 2001:db8:40$(printf "%02d" $i)::1/64
        - 2001:db8:40$(printf "%02d" $i)::2/64
EOL

    echo -e "${GREEN}IPv6 local for $tunnel_name on $server_name server created successfully.${RESET}"
  done

  # Apply netplan configuration for all tunnels
  sudo netplan apply
}

function show_tunnels() {
  clear
  echo -e "${YELLOW}--- Configured Tunnels ---${RESET}"

  for ((i = 1; i <= MAX_TUNNELS; i++)); do
    yaml_file="$NETPLAN_DIR/$YAML_PREFIX$i.yaml"
    tunnel_name="tunnel$(printf "%02d" $i)"

    if [ -e "$yaml_file" ]; then
      ipv6_address=$(grep -oP 'addresses:\s*-\s*\K[^\s]*' "$yaml_file")
      echo -e "${CYAN}$tunnel_name${RESET} - ${CYAN}IPv6: $ipv6_address${RESET}"
    fi
  done
}

function show_ipv6_all() {
  clear
  echo -e "${YELLOW}--- IPv6 Addresses for All Tunnels ---${RESET}"

  for ((i = 1; i <= MAX_TUNNELS; i++)); do
    tunnel_name="tunnel$(printf "%02d" $i)"
    ipv6_address_iran="2001:db8:40$(printf "%02d" $i)::1"
    ipv6_address_kharej="2001:db8:40$(printf "%02d" $i)::2"
    yaml_file="$NETPLAN_DIR/$YAML_PREFIX$i.yaml"

    if [ -e "$yaml_file" ]; then
      echo -e "${CYAN}$tunnel_name - Iran: $ipv6_address_iran, Kharej: $ipv6_address_kharej${RESET}"
    fi
  done
}

function ping_tunnel() {
  valid_tunnels=()

  for ((i = 1; i <= MAX_TUNNELS; i++)); do
    yaml_file="$NETPLAN_DIR/$YAML_PREFIX$i.yaml"
    tunnel_name="tunnel$(printf "%02d" $i)"

    if [ -e "$yaml_file" ]; then
      valid_tunnels+=("$tunnel_name")
    fi
  done

  if [ ${#valid_tunnels[@]} -eq 0 ]; then
    echo -e "${RED}No valid tunnels found.${RESET}"
    return
  fi

  echo -e "${YELLOW}--- Valid Tunnels ---${RESET}"

  for tunnel in "${valid_tunnels[@]}"; do
    echo -e "${CYAN}$tunnel${RESET}"
  done

  read -p "${RED}Enter the tunnel number to ping: ${RESET}" tunnel_number

  if ((tunnel_number < 1 || tunnel_number > MAX_TUNNELS)); then
    echo -e "${RED}Invalid tunnel number. Please enter a number between 1 and $MAX_TUNNELS.${RESET}"
    return
  fi

  ping_tunnel_helper "$tunnel_number"
}

function ping_tunnel_helper() {
  tunnel_number=$1
  tunnel_name="tunnel$(printf "%02d" $tunnel_number)"
  yaml_file="$NETPLAN_DIR/$YAML_PREFIX$tunnel_number.yaml"

  if [ ! -e "$yaml_file" ]; then
    echo -e "${RED}Tunnel $tunnel_name is not configured.${RESET}"
    return
  fi

  clear
  echo -e "${YELLOW}Waiting for 10 pings to $tunnel_name...${RESET}"
  if ping6 -c 10 "${CYAN}2001:db8:40$(printf "%02d" $tunnel_number)::1${RESET}"; then
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

function delete_all_yaml_files() {
  for ((i = 1; i <= MAX_TUNNELS; i++)); do
    yaml_file="$NETPLAN_DIR/$YAML_PREFIX$i.yaml"
    [ -e "$yaml_file" ] && sudo rm -f "$yaml_file"
  done

  sudo netplan apply
  echo -e "${RED}All YAML files deleted.${RESET}"
}

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
