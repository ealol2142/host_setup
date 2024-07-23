#!/usr/bin/env bash

#
# randomization functions
#
# (c) 2016-2018, Hetzner Online GmbH
#

regenerate_snakeoil_ssl_certificate() {
  debug '# regenerate snakeoil ssl certificate'
  local certificate="$FOLD/hdd/etc/ssl/certs/ssl-cert-snakeoil.pem"
  local key="$FOLD/hdd/etc/ssl/private/ssl-cert-snakeoil.key"
  if [[ -e "$certificate" ]]; then rm "$certificate" || return 1; fi
  if [[ -e "$key" ]]; then rm "$key" || return 1; fi
  if installed_os_uses_systemd && ! systemd_nspawn_booted; then
    boot_systemd_nspawn || return 1
  fi
  execute_command_wo_debug DEBIAN_FRONTEND=noninteractive make-ssl-cert generate-default-snakeoil || return 1
  [[ -e "$certificate" ]] && [[ -e "$key" ]]
}

generate_password() {
  local length="${1:-16}"
  local password=''
  until echo "$password" | grep '[[:lower:]]' | grep '[[:upper:]]' | grep -q '[[:digit:]]'; do
    password="$(tr -cd '[:alnum:][:digit:]' < /dev/urandom | head -c "$length")"
  done
  echo "$password"
}

randomize_mysql_root_password() {
  debug '# randomize mysql root password'
  local new_mysql_root_password="$(generate_password)"
  reset_mysql_root_password "$new_mysql_root_password" || return 1
  if grep -q '^ *user *= *root *$' "$FOLD/hdd/etc/mysql/debian.cnf"; then
    sed -i "s/^ *password *=.*$/password = $new_mysql_root_password/g" "$FOLD/hdd/etc/mysql/debian.cnf" || return 1
  fi
  echo "MySQL root password: $new_mysql_root_password" >> "$FOLD/hdd/password.txt"
}

randomize_debian_sys_maint_mysql_password() {
  debug '# randomize debian-sys-maint mysql password'
  local new_debian_sys_maint_mysql_password="$(generate_password)"
  set_mysql_password debian-sys-maint "$new_debian_sys_maint_mysql_password" || return 1
  sed -i "s/^ *password  *=.*$/password = $new_debian_sys_maint_mysql_password/g" "$FOLD/hdd/etc/mysql/debian.cnf" || return 1
  if ! mysql_running; then start_mysql || return 1; fi
  echo QUIT | execute_command_wo_debug mysql --defaults-file=/etc/mysql/debian.cnf -u debian-sys-maint |& debugoutput
  return "${PIPESTATUS[1]}"
}

generate_random_string() {
  local length="${1:-48}"
  tr -cd '[:alnum:][:digit:]' < /dev/urandom | head -c "$length"
}

install_password_txt_hint() {
  debug '# install password.txt hint'
  {
    echo 'echo'
    if lamp_install || hetzner_lamp_install; then
      echo "echo 'This server is running LAMP'"
    elif nextcloud_install; then
      echo "echo 'This server is running Nextcloud'"
    fi
    if hetzner_lamp_install; then
      echo 'echo'
      if debian_buster_image; then
        echo "echo 'Adminer URL: https://<your-servers-ip>/adminer'"
        echo "echo 'Webmin URL:  https://<your-servers-ip>:10000'"
      else
        echo "echo 'phpMyAdmin URL: http://<your-servers-ip>/phpmyadmin'"
        echo "echo 'Webmin URL:     https://<your-servers-ip>:10000'"
      fi
    fi
    echo 'echo'
    echo "echo 'Passwords are listed in /password.txt'"
    echo 'echo'
    if nextcloud_install; then
      echo "echo 'You can access Nextcloud using the following access data:'"
      echo "echo 'Username: root'"
      [[ "$(cat "$FOLD/hdd/password.txt")" =~ $'\n'Nextcloud\ root\ password:\ (.*) ]] || return 1
      echo "echo 'Password: ${BASH_REMATCH[1]}'"
      echo 'echo'
      echo "echo 'Ensure that you change the above password after your first login'"
      echo 'echo'
    fi
    echo "echo 'To remove this hint, please run remove_password_txt_hint'"
    echo 'echo'
  } > "$FOLD/hdd/etc/profile.d/99-$C_SHORT.sh"
}

install_remove_password_txt_hint() {
  debug '# install remove_password_txt_hint'
  {
    echo '#!/usr/bin/env bash'
    echo "rm /etc/profile.d/99-$C_SHORT.sh \$0"
  } > "$FOLD/hdd/usr/local/bin/remove_password_txt_hint"
  chmod 755 "$FOLD/hdd/usr/local/bin/remove_password_txt_hint"
}

randomize_mdadm_array_check_time() {
  local mdcron; mdcron="$FOLD/hdd/etc/cron.d/mdadm"
  local mdtimer; mdtimer="$FOLD/hdd/lib/systemd/system/mdcheck_start.timer"
  declare -i hour minute day
  hour=$(((RANDOM % 4) + 1))
  minute=$(((RANDOM % 59) + 1))
  day=$(((RANDOM % 28) + 1))
  if [ -f "$mdcron" ] && grep -q checkarray "$mdcron"; then
    debug "# Randomizing cronjob run time for mdadm checkarray: day $day @ $hour:$minute"
    sed -i -e "s/^[* 0-9]*root/$minute $hour $day * * root/" -e "s/ &&.*]//" \
      "$mdcron"
  elif [ -f "$mdtimer" ]; then
    debug "# Randomizing systemd timer for mdadm checkarray: day $day @ $hour:$minute"
    local cfgdir; cfgdir="$FOLD/hdd/etc/systemd/system/mdcheck_start.timer.d"
    mkdir -p "$cfgdir"
    local cfg_override; cfg_override="$cfgdir/$C_SHORT.conf"
    {
      echo "[Timer]"
      echo "OnCalendar="
      printf "OnCalendar=*-*-%02d %02d:%02d:00" "$day" "$hour" "$minute"
    } > "$cfg_override"
  else
    debug "# No /etc/cron.d/mdadm or /lib/systemd/system/mdcheck_start.timer found to randomize mdadm checkarray run time"
  fi
}

# vim: ai:ts=2:sw=2:et
