function holla_atcha_boi {

 if [[ "${I_AM_A_RACECAR}" == "y" ]]; 
 then
   RACECAR_CHK='nice -n -19 '
 else
   RACECAR_CHK=""
 fi

 so_check_me_out

  # Do we have an existing chroot set up yet? If not, create.
  if [[ ! -d "root.x86_64/root" || ! -d "root.i686/root" ]];
  then
    echo "No existing chroot environment found. Creating..."
    rm -f ${LOCKFILE}
    ${RACECAR_CHK} ${BASEDIR}/lib/01-mk.chroot.func.sh
    touch ${LOCKFILE}
  fi
}

