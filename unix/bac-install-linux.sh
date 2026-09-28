#!/usr/bin/env bash
# Download, install and configure the latest version of the IBM Storage Protect client automatically.
# If a new version of the client is available, this installer will download it and run the upgrade.
# Usage (download+installation only):
# - ./install_sp_client.sh
# Usage (download+installation+configuration+start scheduler):
# - ./install_sp_client.sh node_name node_password server_host server_port
#
# Tested on:
# - Rocky Linux 8 & 9
# - Debian 12 (bookworm) & 13 (trixie)
# - Ubuntu 20.04 (focal) & Ubuntu 22.04 (jammy) & 24.04 (questing) & 26.04 (resolute)
#
# Safespring's documentation: https://docs.safespring.com/backup/quickstart-guide/
# Support: https://docs.safespring.com/service/support/
#
# Author: Mazen Mardini <mazen.mardini@isstech.io> / <mazen.mardini@safespring.com>
# Date: 2026-09-25
# Version: 1

# Bash error handling
set -Eeuo pipefail

# Arguments
if [[ "$#" -eq 4 ]]; then
  node_name="$1"
  node_password="$2"
  server_host="$3"
  server_port="$4"
elif [[ "$#" -eq 0 ]]; then
  node_name=""
  node_password=""
  server_host=""
  server_port=""
else
  echo "There is an illegal number of arguments."
  echo "Usage: ./$(basename "$0") [node_name node_password server_host server_port]"
  exit 2
fi

# URLs
IBM_SP_FILE_SERVER_URL="https://public.dhe.ibm.com/storage/tivoli-storage-management/maintenance/client/"
SAFESPRING_CA_CERT_URL="https://raw.githubusercontent.com/safespring/cloud-BaaS/master/pki/SafeDC-Net-Root-CA.pem"
DSM_OPT_SAMPLE_URL="https://raw.githubusercontent.com/safespring/cloud-BaaS/master/unix/dsm.opt.sample"
DSM_SYS_SAMPLE_URL="https://raw.githubusercontent.com/safespring/cloud-BaaS/master/unix/dsm.sys.sample"

# Operating System selection
# Add new platforms here.
distro="$(lsb_release --short --id 2>/dev/null || true)"
if [[ $distro == "Debian" || $distro == "Ubuntu" ]]; then
  # Debian / Ubuntu
  os_url_path="Linux/LinuxX86_DEB/BA/"
  file_ending=".tar"
  extract() {
    mkdir -p "$2"
    tar -xvf "$1" --directory "$2"
  }
  install_deps() {
    sudo apt update
    sudo apt install -y curl wget libxml2-utils
  }
  install() {
    find "$(realpath "$1")" -type f -regextype posix-extended -regex '.*(tivsm-ba\.|tivsm-api64|gsk)[^/]*\.deb$' \
         -exec sudo apt install -y {} +
  }
else
  # Rocky Linux / Red Hat / CentOS
  os_url_path="Linux/LinuxX86/BA/"
  file_ending=".tar"
  extract() {
    mkdir -p "$2"
    tar -xvf "$1" --directory "$2"
  }
  install_deps() {
    sudo dnf install -y curl wget
  }
  install() {
    find "$(realpath "$1")" -type f -regextype posix-extended -regex '.*(TIVsm-BA\.|TIVsm-API64|gsk)[^/]*x86_64\.rpm$' \
         -exec sudo dnf install -y {} +
  }
fi

xpath() {
  # Query the response content of URL $1 using XPath $2. Only one return line allowed.
  curl -s "$1" | xmllint --nowarning --html --xpath "$2" - 2>/dev/null
}

die() {
  # Kills the script with an error message.
  # Credits: https://stackoverflow.com/a/75249283
  rc=$?; (( $# )) && printf '%s\n' "$*" >&2; exit $(( rc == 0 ? 1 : rc ));
}

latest_sp_client_url() {
  # Fetch the URL to the latest client archive from IBM.
  # It also ensures that the final URL ends with $file_ending.
  url="$IBM_SP_FILE_SERVER_URL"
  short_version1="$(xpath "$url" 'string(./html/body/pre/a[last()]/@href)')"
  test -n "$short_version1" || die "Could not fetch IBM Storage Protect client URL (empty shortform version #1)."
  url="${url}${short_version1}${os_url_path}"
  short_version2="$(xpath "$url" 'string(./html/body/pre/a[last()]/@href)')"
  test -n "$short_version2" || die "Could not fetch IBM Storage Protect client URL (empty shortform version #2)."
  url="${url}${short_version2}"
  file_name="$(xpath "$url" "string(./html/body/pre/a[substring(@href, string-length(@href) - string-length('$file_ending') + 1) = '$file_ending']/@href)")"
  test -n "$file_name" || die "Could not fetch IBM Storage Protect client URL (empty filename)."
  url="${url}$file_name"
  echo "$url"
}

download() {
  url="$1"
  output_path="$2"
  sudo wget -O "$output_path" "$url" || die "Could not download '$url'"
}

regex_escape() {
  # Escape string for use in sed.
  # Credits: https://stackoverflow.com/a/29613573
  sed 's/[^^]/[&]/g; s/\^/\\^/g' <<< "$1"
}

url_file_stem() {
  # The file name stem (the file name without the extension/suffix)
  url="$1"
  expected_extension="$2"
  # shellcheck disable=SC2001
  echo "$url" | sed "s,.*/\([^/]*\)${expected_extension}$,\1," || die "Failed to parse filename stem from URL '$url'."
}

url_file_name() {
  # shellcheck disable=SC2001
  echo "$1" | sed "s,.*/\([^/]*\)$,\1," || die "Failed to parse filename from URL '$url'."
}

replace_opt() {
  # Replace or add an option to a client configuration file.
  opt_name="$1"
  opt_value="$2"
  file_path="$3"
  old_line="$(grep "^ *$opt_name " "$file_path" || true)"

  if test -n "$old_line"; then
    sudo sed -i "s/$(regex_escape "$old_line")/  $opt_name $opt_value/" "$file_path" \
      || die "Failed to set $opt_name=$opt_value in '$file_path'."
  else
    echo -e "  $opt_name $opt_value" | sudo tee --append "$file_path"
  fi
}

# Before starting, install dependencies
install_deps

# Prepare URLs and paths
client_url="$(latest_sp_client_url)"
client_checksum_url="${client_url}.sha256sum.txt"
installers_path=$(url_file_stem "$client_url" "$file_ending")
archive_path="$installers_path$file_ending"
dsm_opt_sample_path="/opt/tivoli/tsm/client/ba/bin/dsm.opt.sample"
dsm_sys_sample_path="/opt/tivoli/tsm/client/ba/bin/dsm.sys.sample"

# If installers are not available, download and extract them.
extraction_checkpoint_path="$installers_path/extracted"
if ! [ -f "$extraction_checkpoint_path" ]; then
  # Download checksum
  client_checksum_path=$(url_file_name "$client_checksum_url")
  download "$client_checksum_url" "$client_checksum_path"

  # Download and verify the latest client archive
  if ! [ -f "$archive_path" ]; then
    download "$client_url" "$archive_path"
    if ! (sha256sum --check --status < "$client_checksum_path") ; then
      die "Failed checksum verification of '$client_checksum_url' after download."
    fi
  elif ! (sha256sum --check --status < "$client_checksum_path"); then
    rm -f "$archive_path"
    download "$client_url" "$archive_path"
    if ! (sha256sum --check --status < "$client_checksum_path") ; then
      die "Failed checksum verification of '$client_checksum_url' after download."
    fi
  fi

  # Remove old (possibly incomplete) files
  echo "$installers_path" || die ""
  if [ -d "$installers_path" ]; then
    find "$installers_path" -maxdepth 1 -type f -exec rm -f {} +
    rmdir -p "$installers_path"
  fi

  # Extract client archive
  extract "$archive_path" "$installers_path"

  # Clean up
  rm -f "$archive_path"
  rm -f "$client_checksum_path"

  # Checkpoint: All installer files have been extracted and ready for use.
  touch "$extraction_checkpoint_path"

  echo "IBM Storage Protect has been installed!"
fi

# Install the client if it hasn't been installed already
installation_checkpoint_path="$installers_path/installed"
if ! [ -f "$installation_checkpoint_path" ]; then
  # Install client
  install "$installers_path"
  sudo touch /opt/tivoli/tsm/client/ba/bin/dsmcad.lang

  # Make sure that client binaries can access GSK libraries.
  echo "/usr/lib64" | sudo tee /etc/ld.so.conf.d/usr-lib64.conf
  sudo ldconfig

  # Install Safespring's root CA certificate
  ca_cert_path="safespring_root_ca.crt"
  if ! [ -f "$ca_cert_path" ]; then
    download "$SAFESPRING_CA_CERT_URL" "$ca_cert_path"
  fi
  sudo rm -f /opt/tivoli/tsm/client/ba/bin/dsmcert.{crl,kdb,rdb,sth}
  sudo dsmcert -add -server SafeDC -file "$ca_cert_path"

  # Install configuration samples
  if ! [ -f "$dsm_opt_sample_path" ]; then
    download "$DSM_OPT_SAMPLE_URL" "$dsm_opt_sample_path"
    echo -e "\n\n" | sudo tee --append "$dsm_opt_sample_path"
  fi
  if ! [ -f "$dsm_sys_sample_path" ]; then
    download "$DSM_SYS_SAMPLE_URL" "$dsm_sys_sample_path"
    echo -e "\n\n" | sudo tee --append "$dsm_sys_sample_path"
  fi

  # Checkpoint: All installer files have been extracted and ready for use.
  touch "$installation_checkpoint_path"

  echo "IBM Storage Protect has been installed!"
fi

# Configure the client if the user asked for it (arguments were defined)
if test -n "$node_name"; then
  # Create configuration files
  dsm_opt_path="/opt/tivoli/tsm/client/ba/bin/dsm.opt"
  dsm_sys_path="/opt/tivoli/tsm/client/ba/bin/dsm.sys"
  if ! [ -f $dsm_opt_path ]; then
    sudo mv "$dsm_opt_sample_path" "$dsm_opt_path"
  fi
  if ! [ -f $dsm_sys_path ]; then
    sudo mv "$dsm_sys_sample_path" "$dsm_sys_path"
  fi

  # Add/Replace configurations
  replace_opt NODENAME "$node_name" "$dsm_sys_path"
  replace_opt TCPSERVERADDRESS "$server_host" "$dsm_sys_path"
  replace_opt TCPPORT "$server_port" "$dsm_sys_path"
  replace_opt COMMMETHOD TCPIP "$dsm_sys_path"

  # Stop backup scheduler service if it's running
  sudo systemctl stop dsmcad || true

  # Set the password
  sudo dsmc set password "$node_password" "$node_password"

  # Enable and start the backup scheduler
  sudo systemctl enable --now dsmcad

  echo "IBM Storage Protect has been configured!"

  # Present information
  echo ""
  echo "What your /opt/tivoli/tsm/client/ba/bin/dsm.sys looks like:"
  cat "/opt/tivoli/tsm/client/ba/bin/dsm.sys"
  echo ""
  echo "Backup scheduler is running."
  echo "Backup client is ready for use: sudo dsmc"
else
  # Present instructions on what to do next
  echo "Proceed to:"
  echo " 1. Configure /opt/tivoli/tsm/client/ba/bin/dsm.sys by adding the NODENAME, TCPSERVERADDRESS and TCPPORT options."
  echo " 2. Configure the password by running: sudo dsmc set password 'the_password' 'the_password' (Yes, you have to type it twice)"
  echo " 3. (Optional) If you have client-side encryption on (by either using the INCLUDE.ENCRYPT option explicitly, or using the domain FORCE_ENCRYPT), please run a manual backup once to let the client prompt you for the encryption key so that it can save it for future automated backups."
  echo " 4. Enable the scheduler service: sudo systemctl enable --now dsmcad"
fi
