#---------------------------------------------------------------------
# Function: Install Postfix
#    Install and configure postfix
#---------------------------------------------------------------------
InstallPostfix() {
  if [ -f /etc/init.d/sendmail ]; then
	echo -n "Removing Sendmail... "
	systemctl stop sendmail
	hide_output update-rc.d -f sendmail remove
	apt_remove sendmail
	echo -e "[${green}DONE${NC}]\n"
  fi
  
  echo -n "Installing SMTP Mail server (Postfix)... "
  echo "postfix postfix/main_mailer_type select Internet Site" | debconf-set-selections
  echo "postfix postfix/mailname string $CFG_HOSTNAME_FQDN" | debconf-set-selections
  # apt_install postfix postfix-mysql postfix-doc getmail4
  apt_install postfix postfix-mysql postfix-doc postfix-pcre getmail4 ca-certificates
  sed -i '/submission\sinet/,/smtpd_sasl_auth_enable=yes/ s|^#||' /etc/postfix/master.cf
  sed -i "s/  -o smtpd_sasl_auth_enable=yes/  -o smtpd_sasl_auth_enable=yes\\$(echo -e '\n\r')  -o smtpd_client_restrictions=permit_sasl_authenticated,reject/" /etc/postfix/master.cf
  sed -i '/smtps\s+inet/,/smtpd_sasl_auth_enable=yes/ s|^#||' /etc/postfix/master.cf
  sed -i "s/  -o smtpd_sasl_auth_enable=yes/  -o smtpd_sasl_auth_enable=yes\\$(echo -e '\n\r')  -o smtpd_client_restrictions=permit_sasl_authenticated,reject/" /etc/postfix/master.cf
  sed -i "s/#tlsproxy  unix  -       -       y       -       0       tlsproxy/tlsproxy  unix  -       -       y       -       0       tlsproxy/" /etc/postfix/master.cf
  echo -e "[${green}DONE${NC}]\n"
  echo -n "Restarting Postfix... "
  systemctl restart postfix
  echo -e "[${green}DONE${NC}]\n"
}
