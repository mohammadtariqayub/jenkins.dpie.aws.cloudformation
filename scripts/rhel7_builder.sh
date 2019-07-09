#Set motd
cat <<EOF > /etc/motd

                           Notice to Users
        This System is the Property of Trade and Investment NSW
        If you experience any problems please call 02 6363 7676.
                              *NOTE*
==========================================================================
Use of this system constitutes consent to security monitoring and testing.
         All activity is logged with host name and IP address.
                This system is for authorised use only.
==========================================================================
EOF

echo "=========================================================================="
echo "Configure proxy for yum"
echo "proxy=http://amaprdsymprxelb01.dpi.nsw.gov.au:8080" >> /etc/yum.conf

echo "=========================================================================="
echo "Update all packages"
yum check-update
yum update -y

echo "=========================================================================="
echo "Install some useful packages not in the AMI."
yum install -y zip unzip bind-utils traceroute tcpdump python-setuptools dos2unix lsof mlocate bash-completion telnet glibc.i686 wget nfs-utils nmap elinks traceroute tree psmisc sos sysstat aide mailx setools-console setroubleshoot

echo "=========================================================================="
echo "Install packages for Active Directory authentication"
yum install -y sssd realmd samba-common-tools sssd-tools

echo "=========================================================================="
echo "Set proxy environment variables using uploaded file"
dos2unix /root/soft/linux_conf_files/proxy.sh
mv -f /root/soft/linux_conf_files/proxy.sh /etc/profile.d/proxy.sh
chown root:root /etc/profile.d/proxy.sh
chmod 644 /etc/profile.d/proxy.sh
source /etc/profile.d/proxy.sh

echo "=========================================================================="
echo "Install packages for Cloudwatch monitoring"
yum install -y perl-Switch perl-DateTime perl-Sys-Syslog perl-LWP-Protocol-https perl-Digest-SHA --enablerepo="rhui-REGION-rhel-server-optional"
cd /opt
curl https://aws-cloudwatch.s3.amazonaws.com/downloads/CloudWatchMonitoringScripts-1.2.2.zip -O
unzip CloudWatchMonitoringScripts-1.2.2.zip
rm -f CloudWatchMonitoringScripts-1.2.2.zip
cat <<EOF > /etc/cron.d/aws-scripts-mon
SHELL=/bin/bash
PATH=/sbin:/bin:/usr/sbin:/usr/bin
MAILTO=root
*/5 * * * * root /opt/aws-scripts-mon/mon-put-instance-data.pl --mem-used-incl-cache-buff --mem-util --mem-used --mem-avail --swap-util --swap-used --disk-space-util --disk-path=/ --from-cron
EOF

echo "=========================================================================="
echo "Configure and enable sssd"
dos2unix /root/soft/linux_conf_files/sssd.conf
mv -f /root/soft/linux_conf_files/sssd.conf /etc/sssd/sssd.conf
chown root:root /etc/sssd/sssd.conf
chmod 600 /etc/sssd/sssd.conf
authconfig --update --enablesssd --enablesssdauth --enablemkhomedir
systemctl enable sssd
