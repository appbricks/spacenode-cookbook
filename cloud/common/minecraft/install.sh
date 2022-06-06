#!/bin/bash -vx
#
# Install, configure and start a new Minecraft server

set -ex

MINECRAFT_JAR="minecraft_server.jar"

# Update OS and install start script
ubuntu_linux_setup() {
  export SSH_USER="ubuntu"
  export DEBIAN_FRONTEND=noninteractive

  apt-get update
  apt-get -yq install \
    -o Dpkg::Options::="--force-confdef" \
    -o Dpkg::Options::="--force-confold" \
    unattended-upgrades wget lynx unzip openjdk-17-jre-headless \
    awscli jq python3.9 python3-pip python-is-python3

  sed -r \
    -e 's|^//Unattended-Upgrade::MinimalSteps "true";$|Unattended-Upgrade::MinimalSteps "true";|' \
    -e 's|^//Unattended-Upgrade::Automatic-Reboot "false";$|Unattended-Upgrade::Automatic-Reboot "true";|' \
    -e 's|^//Unattended-Upgrade::Remove-Unused-Dependencies "false";|Unattended-Upgrade::Remove-Unused-Dependencies "true";|' \
    -e 's|^//Unattended-Upgrade::Automatic-Reboot-Time "02:00";$|Unattended-Upgrade::Automatic-Reboot-Time "03:00";|' \
    -i /etc/apt/apt.conf.d/50unattended-upgrades

  cat <<"__UPG__" > /etc/apt/apt.conf.d/10periodic
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Download-Upgradeable-Packages "1";
APT::Periodic::AutocleanInterval "7";
APT::Periodic::Unattended-Upgrade "1";
__UPG__

  cat <<SYSTEMD > /etc/systemd/system/minecraft.service
[Unit]
Description=Minecraft Server
After=network.target

[Service]
Type=simple
User=$SSH_USER
WorkingDirectory=${mc_root}
ExecStart=/usr/bin/java -Xmx${java_mx_mem} -Xms${java_ms_mem} -jar $MINECRAFT_JAR nogui
Restart=on-abort

[Install]
WantedBy=multi-user.target
SYSTEMD

  # Start on boot
  /usr/bin/systemctl enable minecraft

  # Install minecraft status query tool
  pip3 install mcstatus
}

download_minecraft_server() {
  WGET=$(which wget)

  # version_manifest.json lists available MC versions
  $WGET -O ${mc_root}/version_manifest.json https://launchermeta.mojang.com/mc/game/version_manifest.json
  if [[ "${mc_type}" == "vanilla" || "${mc_type}" == "paper" ]]; then
    if [[ -z "${mc_version}" ]]; then
      echo "ERROR! For 'vanilla' or 'paper' distribution types a version must be provided."
      exit 1
    fi
    MC_VERSION=${mc_version}
    if [[ "${mc_version}" == "latest" ]]; then
      # Find latest version number if user wants that version (the default)
      MC_VERSION=$(jq -r '.["latest"]["release"]' ${mc_root}/version_manifest.json)
    fi
    DOWNLOAD_URL=https://appbricks-public-downloads.s3.amazonaws.com/minecraft/releases/${mc_type}_$MC_VERSION.zip
  else
    DOWNLOAD_URL=https://appbricks-public-downloads.s3.amazonaws.com/minecraft/releases/${mc_type}.zip
  fi

  set +e
  $WGET -O ${mc_root}/minecraft_distro.zip $DOWNLOAD_URL
  if [[ $? != 0 ]]; then
    set -e
    if [[ "${mc_type}" == "vanilla" ]]; then
      # Index version_manifest.json by the version number and extract URL for the specific version manifest
      VERSIONS_URL=$(jq -r '.["versions"][] | select(.id == "'"$MC_VERSION"'") | .url' ${mc_root}/version_manifest.json)
      # From specific version manifest extract the vanilla server JAR URL
      VANILLA_SERVER_URL=$(curl -s $VERSIONS_URL | jq -r '.downloads | .server | .url')
      # And finally download it to our local MC dir
      $WGET -O ${mc_root}/$MINECRAFT_JAR $VANILLA_SERVER_URL
    else
      echo "ERROR! Distribution package '$TYPE' not found at download URL '$DOWNLOAD_URL'"
      exit 1
    fi
  else
    set -e
    pushd ${mc_root}
    unzip ${mc_root}/minecraft_distro.zip
    popd
  fi
  rm -f ${mc_root}/minecraft_distro.zip
  chown -R ubuntu:ubuntu ${mc_root}
}

ubuntu_linux_setup

# Create mc dir, sync S3 to it and download mc if not already there (from S3)
/bin/mkdir -p ${mc_root}
/usr/bin/aws s3 sync s3://${mc_bucket} ${mc_root}

# Download server if it doesn't exist on S3 already (existing from previous install)
# To force a new server version, remove the server JAR from S3 bucket
if [[ ! -e "${mc_root}/$MINECRAFT_JAR" ]]; then
  download_minecraft_server
fi

# Update minecraft EULA
/bin/cat >${mc_root}/eula.txt<<EULA
eula=true
EULA
# set server description
if [[ "${mc_type}" == "vanilla" || "${mc_type}" == "paper" ]]; then
  if [[ -e "${mc_root}/server.properties" ]]; then
    sed -i -E 's|motd=.*|motd=${mc_description}|' ${mc_root}/server.properties
  else
    echo "motd=${mc_description}" > ${mc_root}/server.properties
  fi
fi

# Cron job to sync data to S3 every five mins
/bin/cat <<CRON > /etc/cron.d/minecraft
SHELL=/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:${mc_root}
*/${mc_backup_freq} * * * *  $SSH_USER  /usr/bin/aws s3 sync ${mc_root} s3://${mc_bucket}
CRON

# CRON job to shutdown when no players are connected
mv /tmp/idle_shutdown.sh ${mc_root}
cat << ---EOF >> /etc/cron.d/minecraft_inactivity_action
SHELL=/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
* * * * *  $SSH_USER  test -x ${mc_root}/idle_shutdown.sh && ${mc_root}/idle_shutdown.sh
---EOF

# Script to update local DNS
mv /tmp/update_dns.sh ${mc_root}

cat <<SYSTEMD > /etc/systemd/system/update-dns.service
[Unit]
Description=Update DNS
After=network.target

[Service]
ExecStart=${mc_root}/update_dns.sh

[Install]
WantedBy=multi-user.target
SYSTEMD

# Run on boot
/usr/bin/systemctl enable update-dns

# Not root
/bin/chown -R $SSH_USER ${mc_root}

/usr/bin/systemctl daemon-reload
/usr/bin/systemctl start update-dns
/usr/bin/systemctl start minecraft

# Clean up
rm /tmp/install.sh
