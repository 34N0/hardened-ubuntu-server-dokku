#!/bin/bash

# Hardening Script for CentOS7 Servers.
# lexpc 07.23

# Color codes for fancy output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No color

# Function to print colored messages
print_success() {
  echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_info() {
  echo -e "${YELLOW}[INFO]${NC} $1"
}

print_error() {
  echo -e "${RED}[PROBLEM]${NC} $1"
}

if [ -n "$SUDO_USER" ]; then
  print_success "Script executed with sudo by user: $SUDO_USER"
else
  print_error "Script must be executed with sudo"
  exit 1
fi
if [ -n "$SUDO_USER" ]; then
  echo "Script executed with sudo by user: $SUDO_USER"
else
  echo "Script must be executed with sudo"
  exit 1
fi

print_info "Making /tmp noexec..."
# Check if the file /etc/systemd/system/tmp.mount exists
if [ ! -f /etc/systemd/system/tmp.mount ]; then
  # If it doesn't exist, copy the file from /usr/lib/systemd/system/tmp.mount
  cp -v /usr/lib/systemd/system/tmp.mount /etc/systemd/system/
fi

# Remove the [Mount] line and the following four lines in the file /etc/systemd/system/tmp.mount
sed -i '/\[Mount\]/,+4d' /etc/systemd/system/tmp.mount

# Append the new [Mount] section to the file /etc/systemd/system/tmp.mount
echo "[Mount]
What=tmpfs
Where=/tmp
Type=tmpfs
Options=mode=1777,strictatime,noexec,nodev,nosuid" >>/etc/systemd/system/tmp.mount

# Reload the systemd daemon
systemctl daemon-reload

# Unmask and start tmp.mount
systemctl --now unmask tmp.mount

# create audit folder
AUDITDIR="/tmp/$(hostname -s)_audit"
TIME="$(date +%F_%T)"

mkdir -p $AUDITDIR

print_info "Disabling Legacy Filesystems"

cat >/etc/modprobe.d/CIS.conf <<"EOF"
install cramfs /bin/true
install freevxfs /bin/true
install jffs2 /bin/true
install hfs /bin/true
install hfsplus /bin/true
install squahfs /bin/true
install udf /bin/true
install dccp /bin/true
install sctp /bin/true
install rds /bin/true
install tipc /bin/true
EOF

print_info "Removing GCC compiler..."
yum -y remove gcc*

print_info "Removing legacy services..."
yum -y remove rsh-server rsh ypserv tftp tftp-server talk talk-server telnet-server xinetd >>$AUDITDIR/service_remove_$TIME.log

print_info "Disabling LDAP..."
yum -y remove openldap-servers >>$AUDITDIR/service_remove_$TIME.log
yum -y remove openldap-clients >>$AUDITDIR/service_remove_$TIME.log

print_info "Disabling DNS..."
yum -y remove bind >>$AUDITDIR/service_remove_$TIME.log

print_info "Disabling FTP Server..."
yum -y remove vsftpd >>$AUDITDIR/service_remove_$TIME.log

print_info "Disabling Dovecot..."
yum -y remove dovecot >>$AUDITDIR/service_remove_$TIME.log

print_info "Disabling Samba..."
yum -y remove samba >>$AUDITDIR/service_remove_$TIME.log

print_info "Disabling HTTP Proxy Server..."
yum -y remove squid >>$AUDITDIR/service_remove_$TIME.log

print_info "Disabling SNMP..."
yum -y remove net-snmp >>$AUDITDIR/service_remove_$TIME.log

print_info "Setting Daemon umask..."
cp /etc/init.d/functions $AUDITDIR/functions_$TIME.bak
echo "umask 027" >>/etc/init.d/functions

print_info "Disabling Unnecessary Services..."
servicelist=(dhcpd avahi-daemon cups nfslock rpcgssd rpcbind rpcidmapd rpcsvcgssd)
for i in ${servicelist[@]}; do
  [ $(systemctl disable $i 2>/dev/null) ] || print_info "$i is Disabled"
done

print_info "Upgrading password hashing algorithm to SHA512..."
authconfig --passalgo=sha512 --update

print_info "Setting core dump security limits..."
echo '* hard core 0' >/etc/security/limits.conf

print_info "Configuring Cron and Anacron..."
yum -y install cronie-anacron >>$AUDITDIR/service_install_$TIME.log
systemctl enable crond
chown root:root /etc/anacrontab
chmod og-rwx /etc/anacrontab
chown root:root /etc/crontab
chmod og-rwx /etc/crontab
chown root:root /etc/cron.hourly
chmod og-rwx /etc/cron.hourly
chown root:root /etc/cron.daily
chmod og-rwx /etc/cron.daily
chown root:root /etc/cron.weekly
chmod og-rwx /etc/cron.weekly
chown root:root /etc/cron.monthly
chmod og-rwx /etc/cron.monthly
chown root:root /etc/cron.d
chmod og-rwx /etc/cron.d
/bin/rm -f /etc/cron.deny

print_info "Creating Banner..."
sed -i "s/\#Banner none/Banner \/etc\/issue\.net/" /etc/ssh/sshd_config
cp -p /etc/issue.net $AUDITDIR/issue.net_$TIME.bak
cat >/etc/issue.net <<'EOF'
**************************************************
*                                                *
*    ██╗     ███████╗██╗  ██╗██████╗  ██████╗    *
*    ██║     ██╔════╝╚██╗██╔╝██╔══██╗██╔════╝    *
*    ██║     █████╗   ╚███╔╝ ██████╔╝██║         *
*    ██║     ██╔══╝   ██╔██╗ ██╔═══╝ ██║         *
*    ███████╗███████╗██╔╝ ██╗██║     ╚██████╗    *
*    ╚══════╝╚══════╝╚═╝  ╚═╝╚═╝      ╚═════╝    *
*    contact: public@lexpc.mozmail.com           *
*                                                *
**************************************************
EOF
cp -p /etc/motd /etc/motd_$TIME.bak
cat >/etc/motd <<'EOF'
LEXPC AUTHORIZED USE ONLY
EOF

print_info "Configuring SSH..."
cp /etc/ssh/sshd_config $AUDITDIR/sshd_config_$TIME.bak
sed -i -e 's/#\?LogLevel.*/LogLevel VERBOSE/g' /etc/ssh/sshd_config
sed -i -e 's/#\?MaxAuthTries.*/MaxAuthTries 4/g' /etc/ssh/sshd_config
sed -i -e 's/#\?IgnoreRhosts.*/IgnoreRhosts yes/g' /etc/ssh/sshd_config
sed -i -e 's/#\?HostbasedAuthentication.*/HostbasedAuthentication no/g' /etc/ssh/sshd_config
sed -i -e 's/#\?PermitRootLogin.*/PermitRootLogin no/g' /etc/ssh/sshd_config
sed -i -e 's/#\?PasswordAuthentication.*/PasswordAuthentication no/g' /etc/ssh/sshd_config
sed -i -e 's/#\?ChallengeResponseAuthentication.*/ChallengeResponseAuthentication no/g' /etc/ssh/sshd_config
sed -i -e 's/#\?PermitEmptyPasswords.*/PermitEmptyPasswords no/g' /etc/ssh/sshd_config
sed -i -e 's/#\?PermitUserEnvironment.*/PermitUserEnvironment no/g' /etc/ssh/sshd_config
sed -i -e 's/#\?ClientAliveInterval.*/ClientAliveInterval 300/g' /etc/ssh/sshd_config
sed -i -e 's/#\?ClientAliveCountMax.*/ClientAliveCountMax 0/g' /etc/ssh/sshd_config

# TODO fix sed
echo "PermitRootLogin no" >>/etc/ssh/sshd_config
echo "PasswordAuthentication no" >>/etc/ssh/sshd_config
echo "ChallengeResponseAuthentication no" >>/etc/ssh/sshd_config

chown root:root /etc/ssh/sshd_config
chmod 600 /etc/ssh/sshd_config

systemctl restart sshd >>$AUDITDIR/service_restart_$TIME.log

print_info "Setting default umask for users..."
line_num=$(grep -n "^[[:space:]]*umask" /etc/bashrc | head -1 | cut -d: -f1)
sed -i ${line_num}s/002/027/ /etc/bashrc
line_num=$(grep -n "^[[:space:]]*umask" /etc/profile | head -1 | cut -d: -f1)
sed -i ${line_num}s/002/027/ /etc/profile

print_info "Locking inactive user accounts..."
useradd -D -f 30

print_info "Verifying System File Permissions..."
chmod 644 /etc/passwd
chmod 000 /etc/shadow
chmod 000 /etc/gshadow
chmod 644 /etc/group
chown root:root /etc/passwd
chown root:root /etc/shadow
chown root:root /etc/gshadow
chown root:root /etc/group

print_info "Setting Sticky Bit on All World-Writable Directories..."
df --local -P | awk {'if (NR!=1) print $6'} | xargs -I '{}' find '{}' -xdev -type d -perm -0002 2>/dev/null | xargs chmod a+t >>$AUDITDIR/sticky_on_world_$TIME.log

print_info "Searching for world writable files..."
df --local -P | awk {'if (NR!=1) print $6'} | xargs -I '{}' find '{}' -xdev -type f -perm -0002 >>$AUDITDIR/world_writable_files_$TIME.log

print_info "Searching for Un-owned files and directories..."
df --local -P | awk {'if (NR!=1) print $6'} | xargs -I '{}' find '{}' -xdev -nouser -ls >>$AUDITDIR/unowned_files_$TIME.log

print_info "Searching for Un-grouped files and directories..."
df --local -P | awk {'if (NR!=1) print $6'} | xargs -I '{}' find '{}' -xdev -nogroup -ls >>$AUDITDIR/ungrouped_files_$TIME.log

print_info "Searching for SUID System Executables..."
df --local -P | awk {'if (NR!=1) print $6'} | xargs -I '{}' find '{}' -xdev -type f -perm -4000 -print >>$AUDITDIR/suid_exec_$TIME.log

print_info "Searching for SGID System Executables..."
df --local -P | awk {'if (NR!=1) print $6'} | xargs -I '{}' find '{}' -xdev -type f -perm -2000 -print >>$AUDITDIR/sgid_exec_$TIME.log

print_info "Searching for empty password fields..."
/bin/cat /etc/shadow | /bin/awk -F: '($2 == "" ) { print $1 " does not have a password "}' >>$AUDITDIR/empty_passwd_$TIME.log

print_info "Reviewing User and Group Settings..."
print_info "Reviewing User and Group Settings..." >>$AUDITDIR/reviewusrgrp_$TIME.log
/bin/grep '^+:' /etc/passwd >>$AUDITDIR/reviewusrgrp_$TIME.log
/bin/grep '^+:' /etc/shadow >>$AUDITDIR/reviewusrgrp_$TIME.log
/bin/grep '^+:' /etc/group >>$AUDITDIR/reviewusrgrp_$TIME.log
/bin/cat /etc/passwd | /bin/awk -F: '($3 == 0) { print $1 }' >>$AUDITDIR/reviewusrgrp_$TIME.log

print_info "Checking root PATH integrity..."

if [ "$(echo $PATH | /bin/grep ::)" != "" ]; then
  echo "Empty Directory in PATH (::)" >>$AUDITDIR/root_path_$TIME.log
fi

if [ "$(echo $PATH | /bin/grep :$)" != "" ]; then
  echo "Trailing : in PATH" >>$AUDITDIR/root_path_$TIME.log
fi

p=$(echo $PATH | /bin/sed -e 's/::/:/' -e 's/:$//' -e 's/:/ /g')
set -- $p
while [ "$1" != "" ]; do
  if [ "$1" = "." ]; then
    echo "PATH contains ." >>$AUDITDIR/root_path_$TIME.log
    shift
    continue
  fi
  if [ -d $1 ]; then
    dirperm=$(/bin/ls -ldH $1 | /bin/cut -f1 -d" ")
    if [ $(echo $dirperm | /bin/cut -c6) != "-" ]; then
      echo "Group Write permission set on directory $1" >>$AUDITDIR/root_path_$TIME.log
    fi
    if [ $(echo $dirperm | /bin/cut -c9) != "-" ]; then
      echo "Other Write permission set on directory $1" >>$AUDITDIR/root_path_$TIME.log
    fi
    dirown=$(ls -ldH $1 | awk '{print $3}')
    if [ "$dirown" != "root" ]; then
      echo "$1 is not owned by root" >>$AUDITDIR/root_path_$TIME.log
    fi
  else
    echo "$1 is not a directory" >>$AUDITDIR/root_path_$TIME.log
  fi
  shift
done

print_info "Checking Permissions on User Home Directories..."

for dir in $(/bin/cat /etc/passwd | /bin/egrep -v '(root|halt|sync|shutdown)' |
  /bin/awk -F: '($8 == "PS" && $7 != "/sbin/nologin") { print $6 }'); do
  dirperm=$(/bin/ls -ld $dir | /bin/cut -f1 -d" ")
  if [ $(echo $dirperm | /bin/cut -c6) != "-" ]; then
    echo "Group Write permission set on directory $dir" >>$AUDITDIR/home_permission_$TIME.log
  fi
  if [ $(echo $dirperm | /bin/cut -c8) != "-" ]; then
    echo "Other Read permission set on directory $dir" >>$AUDITDIR/home_permission_$TIME.log

  fi

  if [ $(echo $dirperm | /bin/cut -c9) != "-" ]; then
    echo "Other Write permission set on directory $dir" >>$AUDITDIR/home_permission_$TIME.log
  fi
  if [ $(echo $dirperm | /bin/cut -c10) != "-" ]; then
    echo "Other Execute permission set on directory $dir" >>$AUDITDIR/home_permission_$TIME.log
  fi
done

print_info "Checking User Dot File Permissions..."
for dir in $(/bin/cat /etc/passwd | /bin/egrep -v '(root|sync|halt|shutdown)' |
  /bin/awk -F: '($7 != "/sbin/nologin") { print $6 }'); do
  for file in $dir/.[A-Za-z0-9]*; do

    if [ ! -h "$file" -a -f "$file" ]; then
      fileperm=$(/bin/ls -ld $file | /bin/cut -f1 -d" ")

      if [ $(echo $fileperm | /bin/cut -c6) != "-" ]; then
        echo "Group Write permission set on file $file" >>$AUDITDIR/dotfile_permission_$TIME.log
      fi
      if [ $(echo $fileperm | /bin/cut -c9) != "-" ]; then
        echo "Other Write permission set on file $file" >>$AUDITDIR/dotfile_permission_$TIME.log
      fi
    fi

  done

done

print_info "Checking Permissions on User .netrc Files..."
for dir in $(/bin/cat /etc/passwd | /bin/egrep -v '(root|sync|halt|shutdown)' |
  /bin/awk -F: '($7 != "/sbin/nologin") { print $6 }'); do
  for file in $dir/.netrc; do
    if [ ! -h "$file" -a -f "$file" ]; then
      fileperm=$(/bin/ls -ld $file | /bin/cut -f1 -d" ")
      if [ $(echo $fileperm | /bin/cut -c5) != "-" ]; then
        echo "Group Read set on $file" >>$AUDITDIR/netrd_permission_$TIME.log
      fi
      if [ $(echo $fileperm | /bin/cut -c6) != "-" ]; then
        echo "Group Write set on $file" >>$AUDITDIR/netrd_permission_$TIME.log
      fi
      if [ $(echo $fileperm | /bin/cut -c7) != "-" ]; then
        echo "Group Execute set on $file" >>$AUDITDIR/netrd_permission_$TIME.log
      fi
      if [ $(echo $fileperm | /bin/cut -c8) != "-" ]; then
        echo "Other Read  set on $file" >>$AUDITDIR/netrd_permission_$TIME.log
      fi
      if [ $(echo $fileperm | /bin/cut -c9) != "-" ]; then
        echo "Other Write set on $file" >>$AUDITDIR/netrd_permission_$TIME.log
      fi
      if [ $(echo $fileperm | /bin/cut -c10) != "-" ]; then
        echo "Other Execute set on $file" >>$AUDITDIR/netrd_permission_$TIME.log
      fi
    fi
  done
done

print_info "Checking for Presence of User .rhosts Files..."
for dir in $(/bin/cat /etc/passwd | /bin/egrep -v '(root|halt|sync|shutdown)' |
  /bin/awk -F: '($7 != "/sbin/nologin") { print $6 }'); do
  for file in $dir/.rhosts; do
    if [ ! -h "$file" -a -f "$file" ]; then
      echo ".rhosts file in $dir" >>$AUDITDIR/rhosts_$TIME.log
    fi
  done
done

print_info "Checking Groups in /etc/passwd..."

for i in $(cut -s -d: -f4 /etc/passwd | sort -u); do
  grep -q -P "^.*?:x:$i:" /etc/group
  if [ $? -ne 0 ]; then
    echo "Group $i is referenced by /etc/passwd but does not exist in /etc/group" >>$AUDITDIR/audit_$TIME.log
  fi
done

print_info "Checking That Users Are Assigned Home Directories..."

cat /etc/passwd | awk -F: '{ print $1 " " $3 " " $6 }' | while read user uid dir; do
  if [ $uid -ge 500 -a ! -d "$dir" -a $user != "nfsnobody" ]; then
    echo "The home directory ($dir) of user $user does not exist." >>$AUDITDIR/audit_$TIME.log
  fi
done

print_info "Checking That Defined Home Directories Exist..."

cat /etc/passwd | awk -F: '{ print $1 " " $3 " " $6 }' | while read user uid dir; do
  if [ $uid -ge 500 -a -d "$dir" -a $user != "nfsnobody" ]; then
    owner=$(stat -L -c "%U" "$dir")
    if [ "$owner" != "$user" ]; then
      echo "The home directory ($dir) of user $user is owned by $owner." >>$AUDITDIR/audit_$TIME.log
    fi
  fi
done

print_info "Checking for Duplicate UIDs..."

/bin/cat /etc/passwd | /bin/cut -f3 -d":" | /bin/sort -n | /usr/bin/uniq -c |
  while read x; do
    [ -z "${x}" ] && break
    set - $x
    if [ $1 -gt 1 ]; then
      users=$(/bin/gawk -F: '($3 == n) { print $1 }' n=$2 \
        /etc/passwd | /usr/bin/xargs)
      echo "Duplicate UID ($2): ${users}" >>$AUDITDIR/audit_$TIME.log
    fi
  done

print_info "Checking for Duplicate GIDs..."

/bin/cat /etc/group | /bin/cut -f3 -d":" | /bin/sort -n | /usr/bin/uniq -c |
  while read x; do
    [ -z "${x}" ] && break
    set - $x
    if [ $1 -gt 1 ]; then
      grps=$(/bin/gawk -F: '($3 == n) { print $1 }' n=$2 \
        /etc/group | xargs)
      echo "Duplicate GID ($2): ${grps}" >>$AUDITDIR/audit_$TIME.log
    fi
  done

print_info "Checking That Reserved UIDs Are Assigned to System Accounts..."

defUsers="root bin daemon adm lp sync shutdown halt mail news uucp operator games
gopher ftp nobody nscd vcsa rpc mailnull smmsp pcap ntp dbus avahi sshd rpcuser
nfsnobody haldaemon avahi-autoipd distcache apache oprofile webalizer dovecot squid
named xfs gdm sabayon usbmuxd rtkit abrt saslauth pulse postfix tcpdump"
/bin/cat /etc/passwd | /bin/awk -F: '($3 < 500) { print $1" "$3 }' |
  while read user uid; do
    found=0
    for tUser in ${defUsers}; do
      if [ ${user} = ${tUser} ]; then
        found=1
      fi
    done
    if [ $found -eq 0 ]; then
      echo "User $user has a reserved UID ($uid)." >>$AUDITDIR/audit_$TIME.log
    fi
  done

print_info "Checking for Duplicate User Names..."

cat /etc/passwd | cut -f1 -d":" | sort -n | /usr/bin/uniq -c |
  while read x; do
    [ -z "${x}" ] && break
    set - $x
    if [ $1 -gt 1 ]; then
      uids=$(/bin/gawk -F: '($1 == n) { print $3 }' n=$2 \
        /etc/passwd | xargs)
      echo "Duplicate User Name ($2): ${uids}" >>$AUDITDIR/audit_$TIME.log
    fi
  done

print_info "Checking for Duplicate Group Names..."

cat /etc/group | cut -f1 -d":" | /bin/sort -n | /usr/bin/uniq -c |
  while read x; do
    [ -z "${x}" ] && break
    set - $x
    if [ $1 -gt 1 ]; then
      gids=$(/bin/gawk -F: '($1 == n) { print $3 }' n=$2 \
        /etc/group | xargs)
      echo "Duplicate Group Name ($2): ${gids}" >>$AUDITDIR/audit_$TIME.log
    fi
  done

print_info "Checking for Presence of User .netrc Files..."

for dir in $(/bin/cat /etc/passwd |
  /bin/awk -F: '{ print $6 }'); do
  if [ ! -h "$dir/.netrc" -a -f "$dir/.netrc" ]; then
    echo ".netrc file $dir/.netrc exists" >>$AUDITDIR/audit_$TIME.log
  fi
done

print_info "Checking for Presence of User .forward Files..."

for dir in $(/bin/cat /etc/passwd |
  /bin/awk -F: '{ print $6 }'); do
  if [ ! -h "$dir/.forward" -a -f "$dir/.forward" ]; then
    echo ".forward file $dir/.forward exists" >>$AUDITDIR/audit_$TIME.log
  fi
done

print_info "Modifying Network Parameters..."
cp /etc/sysctl.conf $AUDITDIR/sysctl.conf_$TIME.bak

cat >/etc/sysctl.conf <<'EOF'
net.ipv4.ip_forward=0
net.ipv4.conf.all.send_redirects=0
net.ipv4.conf.default.send_redirects=0
net.ipv4.conf.all.accept_source_route=0
net.ipv4.conf.default.accept_source_route=0
net.ipv4.conf.all.accept_redirects=0
net.ipv4.conf.default.accept_redirects=0
net.ipv4.conf.all.secure_redirects=0
net.ipv4.conf.default.secure_redirects=0
net.ipv4.conf.all.log_martians=1
net.ipv4.conf.default.log_martians=1
net.ipv4.route.flush=1
net.ipv4.icmp_echo_ignore_broadcasts=1
net.ipv4.icmp_ignore_bogus_error_responses=1
net.ipv4.conf.all.rp_filter=1
net.ipv4.conf.default.rp_filter=1
net.ipv4.tcp_syncookies=1
net.ipv6.conf.all.accept_ra=0
net.ipv6.conf.default.accept_ra=0
net.ipv6.conf.all.accept_redirects=0
net.ipv6.conf.default.accept_redirects=0
EOF

print_info "Disabling IPv6..."
cp /etc/sysconfig/network $AUDITDIR/network_$TIME.bak
echo "NETWORKING_IPV6=no" >>/etc/sysconfig/network
echo "IPV6INIT=no" >>/etc/sysconfig/network
echo "options ipv6 disable=1" >>/etc/modprobe.d/ipv6.conf
echo "net.ipv6.conf.all.disable_ipv6=1" >>/etc/sysctl.d/ipv6.conf

# Install Firewalld package
print_info "Installing Firewalld..."
sudo yum install -y firewalld

# Start and enable Firewalld service
print_info "Starting and enabling Firewalld service..."
sudo systemctl start firewalld
sudo systemctl enable firewalld

# Configure Firewalld to block all incoming traffic by default
print_info "Configuring Firewalld to block all incoming traffic..."
sudo firewall-cmd --set-default-zone=drop

# Allow SSH traffic
print_info "Allowing SSH traffic..."
sudo firewall-cmd --zone=drop --add-service=ssh --permanent

# Allow HTTP and HTTPS traffic
print_info "Allowing HTTP and HTTPS traffic..."
sudo firewall-cmd --zone=drop --add-service=http --permanent
sudo firewall-cmd --zone=drop --add-service=https --permanent

# Reload Firewalld to apply the changes
print_info "Reloading Firewalld to apply the changes..."
sudo firewall-cmd --reload

print_info "Enabling SELinux"
# Check if SELinux is already set to enforcing mode
if [ "$(getenforce)" != "Enforcing" ]; then
  # Set SELinux to enforcing mode
  setenforce 1
fi

# Set default umask to 077
print_info "Setting default umask to 077 in /etc/profile..."
sudo perl -npe 's/umask\s+0\d2/umask 077/g' -i /etc/bashrc
sudo perl -npe 's/umask\s+0\d2/umask 077/g' -i /etc/csh.cshrc

print_info "Restricting Access to the su Command..."
cp /etc/pam.d/su $AUDITDIR/su_$TIME.bak
pam_su='/etc/pam.d/su'
line_num="$(grep -n "^\#auth[[:space:]]*required[[:space:]]*pam_wheel.so[[:space:]]*use_uid" ${pam_su} | cut -d: -f1)"
sed -i "${line_num} a auth		required	pam_wheel.so use_uid" ${pam_su}

echo ""
print_success "Successfully Completed"
print_info "Please check $AUDITDIR"
