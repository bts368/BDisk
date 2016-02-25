function yo_dj () {

  FUNCNAME="yo_dj"

  ARCH="${1}"
  echo "Building the actual .iso image. This may take a while."
  #im_batman ## WHYTF IS THIS HERE?!
  ISOFILENAME="${UXNAME}-${BUILDVERSION}.iso"
  #MINIFILENAME="${UXNAME}-${BUILDVERSION}-mini.iso"
  MINIFILENAME="${UXNAME}-mini.iso"
  USBFILENAME="${UXNAME}-mini.usb.img"
  if [[ "${MULTIARCH}" == "y" ]];
  then
    ISOFILENAME="${UXNAME}-${BUILDVERSION}-any.iso"
  else
    ISOFILENAME="${UXNAME}-${BUILDVERSION}-${ARCH}.iso"
  fi

  if [[ "${I_AM_A_RACECAR}" == "y" ]]; 
  then
    RACECAR_CHK='nice -n -19 '
  else
    RACECAR_CHK=""
  fi

  # and why not? generate the ISO.
  ## we need to generate the isolinux.cfg
  mkdir -p ${TEMPDIR}/isolinux
  if [[ "${MULTIARCH}" == "y" ]];
  then
   ## MULTIARCH ISO
   cat > ${TEMPDIR}/isolinux/isolinux.cfg << EOF
UI vesamenu.c32
DEFAULT check
PROMPT 0
TIMEOUT 50
MENU HIDDEN
#ONTIMEOUT ${UXNAME}_ram
ONTIMEOUT check
MENU TABMSG Press [TAB] to edit options
#MENU TITLE ${PNAME} (ISO edition)
MENU ROWS 16
MENU TIMEOUTROW 22
MENU TABMSGROW 24
MENU CMDLINEROW 24
MENU HELPMSGROW 26
MENU WIDTH 78
MENU MARGIN 6
MENU IMMEDIATE
# http://www.colorpicker.com/
MENU color border   0 	        #00000000 #00000000 none
MENU color title    0    	#FFF5B800 #00000000 std 
MENU color sel      7;37;40    #FF000000 #FFFFFFFF all 
MENU color hotsel   1;7;37;40  #FFFF0000 #FFC0C0C0 all 
MENU color hotkey   1;7;37;40  #FF0000CC #FFC0C0C0 all 
MENU color tabmsg   1;31;40    #FF808080 #00000000 std 
MENU color help     1;31;40    #FFFFFFFF #FF000000 none
MENU color timeout_msg 0       #FFFFB300 #00000000 none
MENU color timeout  0          #FFFF0000 #FF000000 none
MENU color cmdline  0          #FFFFFFFF #FF000000 none
MENU color cmdmark  1;36;40    #C000FFFF #FF000000 std 
MENU color scrollbar 30;44     #FF00FF00 #FF000000 std 
MENU color msg07    0          #FF000000 #00FFFFFF none
MENU BACKGROUND /${UXNAME}.png

LABEL check
  MENU LABEL Your best supported kernel should be detected automatically.
  COM32 ifcpu64.c32
  APPEND ${UXNAME}_64 -- ${UXNAME}_32
  MENU DEFAULT



LABEL local_override
  MENU LABEL Local ^Boot
  localboot 0
  TEXT HELP
  Boot from the local system instead.
  ENDTEXT 

LABEL reboot
  MENU LABEL ^Reboot
  COM32 reboot.c32
  TEXT HELP
  Reboot the machine
  ENDTEXT

MENU SEPARATOR

## 64 BIT
MENU BEGIN 64BIT
MENU LABEL ^1) 64-Bit ...
ONTIMEOUT ${UXNAME}_64
  
LABEL ${UXNAME}_ram_64
  MENU LABEL ^1) ${PNAME} (run from RAM)
  LINUX /boot/${UXNAME}.64.kern
  INITRD /boot/${UXNAME}.64.img
  APPEND copytoram archisobasedir=${DISTNAME} archisolabel=${DISTNAME}
  TEXT HELP
  64-bit, run from RAM
  ENDTEXT
  MENU DEFAULT

LABEL ${UXNAME}_64 
  MENU LABEL ^1) ${PNAME} (Default)
  LINUX /boot/${UXNAME}.64.kern
  INITRD /boot/${UXNAME}.64.img
  APPEND archisobasedir=${DISTNAME} archisolabel=${DISTNAME}
  TEXT HELP
  Same as the above, except run directly from the CD-
  don't copy the image to RAM. (Best for lower-memory boxes)
  ENDTEXT

MENU END

MENU BEGIN 32BIT
MENU LABEL ^2) 32-Bit ...
ONTIMEOUT ${UXNAME}_32

## 32 BIT
LABEL ${UXNAME}_ram_32
  MENU LABEL ^1) ${PNAME} (run from RAM)
  LINUX /boot/${UXNAME}.32.kern
  INITRD /boot/${UXNAME}.32.img
  APPEND copytoram archisobasedir=${DISTNAME} archisolabel=${DISTNAME}
  TEXT HELP
  32-bit, run from RAM
  ENDTEXT
  MENU DEFAULT

LABEL ${UXNAME}_32 
  MENU LABEL ^2) ${PNAME} (Default)
  LINUX /boot/${UXNAME}.32.kern
  INITRD /boot/${UXNAME}.32.img
  APPEND archisobasedir=${DISTNAME} archisolabel=${DISTNAME}
  TEXT HELP
  Same as the above, except run directly from the CD-
  don't copy the image to RAM. (Best for lower-memory boxes)
  ENDTEXT

MENU END
EOF
  else
   ## ARCH-SPECIFIC ISO
   cat > ${TEMPDIR}/isolinux/isolinux.cfg << EOF
UI vesamenu.c32
DEFAULT check
PROMPT 0
TIMEOUT 50
MENU HIDDEN
ONTIMEOUT ${UXNAME}_ram_${ARCH}
MENU TABMSG Press [TAB] to edit options
#MENU TITLE ${PNAME} (ISO edition)
MENU ROWS 16
MENU TIMEOUTROW 22
MENU TABMSGROW 24
MENU CMDLINEROW 24
MENU HELPMSGROW 26
MENU WIDTH 78
MENU MARGIN 6
MENU IMMEDIATE
# http://www.colorpicker.com/
MENU color border   0 	        #00000000 #00000000 none
MENU color title    0    	#FFF5B800 #00000000 std 
MENU color sel      7;37;40    #FF000000 #FFFFFFFF all 
MENU color hotsel   1;7;37;40  #FFFF0000 #FFC0C0C0 all 
MENU color hotkey   1;7;37;40  #FF0000CC #FFC0C0C0 all 
MENU color tabmsg   1;31;40    #FF808080 #00000000 std 
MENU color help     1;31;40    #FFFFFFFF #FF000000 none
MENU color timeout_msg 0       #FFFFB300 #00000000 none
MENU color timeout  0          #FFFF0000 #FF000000 none
MENU color cmdline  0          #FFFFFFFF #FF000000 none
MENU color cmdmark  1;36;40    #C000FFFF #FF000000 std 
MENU color scrollbar 30;44     #FF00FF00 #FF000000 std 
MENU color msg07    0          #FF000000 #00FFFFFF none
MENU BACKGROUND /${UXNAME}.png

LABEL local_override
  MENU LABEL Local ^Boot
  localboot 0
  TEXT HELP
  Boot from the local system instead.
  ENDTEXT 

LABEL reboot
  MENU LABEL ^Reboot
  COM32 reboot.c32
  TEXT HELP
  Reboot the machine
  ENDTEXT

MENU SEPARATOR

MENU BEGIN ${ARCH}BIT
MENU LABEL ^1) ${ARCH}-Bit ...
ONTIMEOUT ${UXNAME}_${ARCH}
  
LABEL ${UXNAME}_ram_${ARCH}
  MENU LABEL ^1) ${PNAME} (run from RAM)
  LINUX /boot/${UXNAME}.${ARCH}.kern
  INITRD /boot/${UXNAME}.${ARCH}.img
  APPEND copytoram archisobasedir=${DISTNAME} archisolabel=${DISTNAME}
  TEXT HELP
  ${ARCH}-bit, run from RAM
  ENDTEXT
  MENU DEFAULT

LABEL ${UXNAME}_${ARCH} 
  MENU LABEL ^1) ${PNAME} (Default)
  LINUX /boot/${UXNAME}.${ARCH}.kern
  INITRD /boot/${UXNAME}.${ARCH}.img
  APPEND archisobasedir=${DISTNAME} archisolabel=${DISTNAME}
  TEXT HELP
  Same as the above, except run directly from the CD-
  don't copy the image to RAM. (Best for lower-memory boxes)
  ENDTEXT

MENU END
EOF
  fi 

  stuffy

  rm -f ${ISOFILENAME}
  if [ "${ARCHBOOT}" != "${TEMPDIR}/${DISTNAME}" ];
  then
   mkdir -p ${TEMPDIR}/${DISTNAME}
   rsync -a --delete ${ARCHBOOT}/. ${TEMPDIR}/${DISTNAME}/.
  fi
  cp -af ${BASEDIR}/root.x86_64/usr/lib/syslinux/bios/isolinux.bin ${TEMPDIR}/isolinux
  #cp -af ${BASEDIR}/root.x86_64/usr/lib/syslinux/bios/isolinux-debug.bin ${TEMPDIR}/isolinux/isolinux.bin #debugging
  #cp -af ${BASEDIR}/root.x86_64/usr/lib/syslinux/bios/* ${TEMPDIR}/isolinux/. #debugging
  cp -af ${BASEDIR}/root.x86_64/usr/lib/syslinux/bios/vesamenu.c32 ${TEMPDIR}/isolinux
  cp -af ${BASEDIR}/root.x86_64/usr/lib/syslinux/bios/linux.c32 ${TEMPDIR}/isolinux
  cp -af ${BASEDIR}/root.x86_64/usr/lib/syslinux/bios/reboot.c32 ${TEMPDIR}/isolinux
  if [ -f ${BASEDIR}/root.x86_64/usr/lib/syslinux/bios/ldlinux.c32 ];
  then
    cp -af ${BASEDIR}/root.x86_64/usr/lib/syslinux/bios/ldlinux.c32 ${TEMPDIR}/isolinux
  fi
  if [ -f ${BASEDIR}/root.x86_64/usr/lib/syslinux/bios/libcom32.c32 ];
  then
    cp -af ${BASEDIR}/root.x86_64/usr/lib/syslinux/bios/libcom32.c32 ${TEMPDIR}/isolinux
  fi
  if [ -f ${BASEDIR}/root.x86_64/usr/lib/syslinux/bios/libutil.c32 ];
  then
    cp -af ${BASEDIR}/root.x86_64/usr/lib/syslinux/bios/libutil.c32 ${TEMPDIR}/isolinux
  fi
  if [ -f ${BASEDIR}/root.x86_64/usr/lib/syslinux/bios/ifcpu64.c32 ];
  then
    cp -af ${BASEDIR}/root.x86_64/usr/lib/syslinux/bios/ifcpu64.c32 ${TEMPDIR}/isolinux
  fi
  cd ${TEMPDIR}

  cd ..
  ${RACECAR_CHK}xorriso -as mkisofs \
`#-quiet` \
`#-joliet` \
`#-rock` \
`#-omit-version-number` \
`#-disable-deep-relocation` \
-iso-level 3 \
-full-iso9660-filenames \
-volid "${DISTNAME}" \
-appid "${DISTDESC}" \
-publisher "${DISTPUB}" \
`#-preparer "prepared by ${0}"` \
-preparer "prepared by ${DISTPUB}" \
-eltorito-boot isolinux/isolinux.bin \
-eltorito-catalog isolinux/boot.cat \
`#-isohybrid-mbr ${BASEDIR}/root.x86_64/usr/lib/syslinux/bios/isohdpfx.bin` \
-no-emul-boot \
-boot-load-size 4 \
-boot-info-table \
-isohybrid-mbr ${BASEDIR}/root.x86_64/usr/lib/syslinux/bios/isohdpfx.bin \
-eltorito-alt-boot \
-e EFI/${DISTNAME}/efiboot.img \
-no-emul-boot \
`#--efi-boot EFI/${DISTNAME}/efiboot.img` \
-isohybrid-gpt-basdat \
-output "${ISODIR}/${ISOFILENAME}" "${TEMPDIR}" >> "${LOGFILE}.${FUNCNAME}" 2>&1

  ## Build the mini-ISO ##
  if [[ "${BUILDMINI}" == "y" ]];
  then
    echo "Now generating the iPXE images; please wait..."
    ## Get the latest version of ipxe from git.
    git submodule init >> "${LOGFILE}.${FUNCNAME}" 2>&1
    git submodule update >> "${LOGFILE}.${FUNCNAME}" 2>&1
    cd ${BASEDIR}/src/ipxe/src
    git clean -xdf > /dev/null 2>&1
    git reset --hard HEAD >> "${LOGFILE}.${FUNCNAME}" 2>&1
    git checkout master >> "${LOGFILE}.${FUNCNAME}" 2>&1
    git pull >> "${LOGFILE}.${FUNCNAME}" 2>&1
    git checkout master >> "${LOGFILE}.${FUNCNAME}" 2>&1
    # It will not build if we don't do this. Apparently we *need* libiberty.
    git revert -n 40a9a0f0
    ## Apply our patches.
    for i in $(find ${BASEDIR}/src/ipxe_local/patches/ -type f -iname "*.patch" -printf '%P\n' | sort);
    do
      patch -Np2 < ${BASEDIR}/src/ipxe_local/patches/${i} >> "${LOGFILE}.${FUNCNAME}" 2>&1
    done
    ## SSL
    SSLDIR="${BASEDIR}/src/ipxe_local/ssl"
    mkdir -p ${SSLDIR}/{keys,crts,txt}
    chmod 000 ${SSLDIR}/keys
    chown root:root ${SSLDIR}/keys
    if [[ -z "${IPXE_SSL_CA}" && -z "${IPXE_SSL_KEY}" ]];
    then
      # Generate SSL CA
      #rm -rf ${SSLDIR}/*
      cd "${SSLDIR}"
      IPXE_SSL_CA="${SSLDIR}/crts/ca.crt"
      IPXE_SSL_CAKEY="${SSLDIR}/keys/ca.key"
      IPXE_DOMAIN=$(echo ${IPXE_URI} | sed -re 's/^(f|ht)tps?:\/\/// ; s/\/.*//')
      if [[ ! -f "${SSLDIR}/txt/ca.srl" ]];
      then
        echo 01 > ${SSLDIR}/txt/ca.srl
      fi
      touch ${SSLDIR}/txt/ca.idx
      openssl req -days 3650 -subj "/CN=${IPXE_DOMAIN}/O=${PNAME}/C=NA" -x509 -newkey rsa:4096 -nodes -out ${IPXE_SSL_CA} -keyout ${IPXE_SSL_CAKEY} -sha512 >> "${LOGFILE}.${FUNCNAME}" 2>&1
      openssl req -days 3650 -subj "/CN=${IPXE_DOMAIN}/O=${PNAME}/C=NA" -newkey rsa:4096 -keyout ${SSLDIR}/keys/server.key -nodes -out ${SSLDIR}/crts/server.csr -sha512 >> "${LOGFILE}.${FUNCNAME}" 2>&1
      openssl ca -days 3650 -batch -config ${SSLDIR}/openssl.cnf -keyfile ${IPXE_SSL_CAKEY} -in ${SSLDIR}/crts/server.csr -out ${SSLDIR}/crts/server.crt >> "${LOGFILE}.${FUNCNAME}" 2>&1
      #cat crts/server.crt crts/ca.crt > crts/server_chained.crt
    elif [[ -z "${IPXE_SSL_CA}" && -e "${IPXE_SSL_CAKEY}" ]];
    then
      echo "ERROR: You specified IPXE_SSL_CAKEY but not IPXE_SSL_CA. If one is specified, the other must be also."
      exit 1
    elif [[ -z "${IPXE_SSL_CAKEY}" && -e "${IPXE_SSL_CA}" ]];
    then
      echo "ERROR: You specified IPXE_SSL_CA but not IPXE_SSL_CAKEY. If one is specified, the other must be also."
      exit 1
    elif [[ ! -e "${IPXE_SSL_CA}" || ! -e "${IPXE_SSL_CAKEY}" ]];
    then
      echo "ERROR: You have specified both IPXE_SSL_CA and IPXE_SSL_CAKEY but one (or both) are not valid paths/files."
      exit 1
    fi
    if [[ -z "${IPXE_SSL_KEY}" && -z "${IPXE_SSL_CRT}" ]];
    then
      IPXE_SSL_KEY="${SSLDIR}/keys/client.key"
      IPXE_SSL_CRT="${SSLDIR}/crts/client.crt"
      IPXE_DOMAIN=$(echo ${IPXE_URI} | sed -re 's/^(f|ht)tps?:\/\/// ; s/\/.*//')
      # Generate SSL client key.
      openssl req -days 3650 -subj "/CN=${IPXE_DOMAIN}/O=${PNAME}/C=NA" -newkey rsa:4096 -keyout ${IPXE_SSL_KEY} -nodes -out ${SSLDIR}/crts/client.csr -sha512 >> "${LOGFILE}.${FUNCNAME}" 2>&1
      # Sign the crt.
      openssl ca -days 3650 -batch -config ${SSLDIR}/openssl.cnf -keyfile ${IPXE_SSL_CAKEY} -in ${SSLDIR}/crts/client.csr -out ${IPXE_SSL_CRT} >> "${LOGFILE}.${FUNCNAME}" 2>&1
    elif [[ -z "${IPXE_SSL_CRT}" && -e "${IPXE_SSL_KEY}" ]]; 
    then
      echo "ERROR: You specified IPXE_SSL_KEY but not IPXE_SSL_CRT. If one is specified, the other must be also."
      exit 1
    elif [[ -z "${IPXE_SSL_KEY}" && -e "${IPXE_SSL_CRT}" ]]; 
    then
      echo "ERROR: You specified IPXE_SSL_CRT but not IPXE_SSL_KEY. If one is specified, the other must be also."
      exit 1
    elif [[ ! -e "${IPXE_SSL_CRT}" || ! -e "${IPXE_SSL_KEY}" ]]; 
    then
      echo "ERROR: You have specified both IPXE_SSL_CRT and IPXE_SSL_KEY but one (or both) are not valid paths/files."
      exit 1
    fi
    cd ${BASEDIR}/src/ipxe/src
    # Generate the iPXE EMBED script...
    sed -re "s,^(chain\ ).*$,\1${IPXE_URI},g" \
	-e 's/%%COMMA%%/,/g' ${BASEDIR}/src/ipxe_local/EMBED > ${SRCDIR}/EMBED
    # And now we build!
    #make everything EMBED="${SRCDIR}/EMBED" >> "${LOGFILE}.${FUNCNAME}" 2>&1
    make bin-i386-efi/ipxe.efi bin-x86_64-efi/ipxe.efi \
         EMBED="${SRCDIR}/EMBED" \
         TRUST="${IPXE_SSL_CA}" \
         CERT="${IPXE_SSL_CA},${IPXE_SSL_CRT}" \
         PRIVKEY="${IPXE_SSL_KEY}" >> "${LOGFILE}.${FUNCNAME}" 2>&1
    make bin/ipxe.eiso bin/ipxe.usb \
         EMBED="${SRCDIR}/EMBED" \
         TRUST="${IPXE_SSL_CA}" \
         CERT="${IPXE_SSL_CA},${IPXE_SSL_CRT}" \
         PRIVKEY="${IPXE_SSL_KEY}" >> "${LOGFILE}.${FUNCNAME}" 2>&1
    # Change this to USB-only...
    #make all EMBED="${BASEDIR}/src/ipxe_local/EMBED" >> "${LOGFILE}.${FUNCNAME}" 2>&1
    mv -f ${BASEDIR}/src/ipxe/src/bin/ipxe.usb  ${ISODIR}/${USBFILENAME}
    mv -f ${BASEDIR}/src/ipxe/src/bin/ipxe.eiso  ${ISODIR}/${MINIFILENAME}
    make clean >> "${LOGFILE}.${FUNCNAME}" 2>&1
    cd ${BASEDIR}/src/ipxe
    git clean -xdf > /dev/null 2>&1
    git reset --hard >> "${LOGFILE}.${FUNCNAME}" 2>&1
    git checkout master . > /dev/null 2>&1
    #git reset --hard HEAD > /dev/null 2>&1
    echo
  fi

  #isohybrid ${ISOFILENAME}
  cd ${ISODIR}
  ${RACECAR_CHK}sha256sum ${ISOFILENAME} > ${ISOFILENAME}.sha256
  if [[ "${BUILDMINI}" == "y" ]];
  then
    ${RACECAR_CHK}sha256sum ${MINIFILENAME} > ${MINIFILENAME}.sha256
    ${RACECAR_CHK}sha256sum ${USBFILENAME} > ${USBFILENAME}.sha256
  fi
  cd ..
  echo "=ISO="
  echo "Size: $(ls -lh ${ISODIR}/${ISOFILENAME} | awk '{print $5}')"
  echo "SHA256: $(awk '{print $1}' ${ISODIR}/${ISOFILENAME}.sha256)"
  echo "Location: ${ISODIR}/${ISOFILENAME}"
  if [[ "${BUILDMINI}" == "y" ]];
  then
    echo "=Mini="
    echo "Size: $(ls -lh ${ISODIR}/${MINIFILENAME} | awk '{print $5}')"
    echo "SHA256: $(awk '{print $1}' ${ISODIR}/${MINIFILENAME}.sha256)"
    echo "Location: ${ISODIR}/${MINIFILENAME}"
    echo "=Mini USB="
    echo "Size: $(ls -lh ${ISODIR}/${USBFILENAME} | awk '{print $5}')"
    echo "SHA256: $(awk '{print $1}' ${ISODIR}/${USBFILENAME}.sha256)"
    echo "Location: ${ISODIR}/${USBFILENAME}"
  fi
  #rm -rf ${TEMPDIR}/*

  # are we rsyncing?
  if [ -n "${RSYNC_HOST}" ];
  then
   echo
   echo "Now sending to ${RSYNC_HOST} via rsync. This may take a while..."
   echo "Sending TFTP files..."
   rsync -az --info=progress2 ${TFTPDIR} ${RSYNC_HOST}:${RSYNC_DEST}/.
   echo "Sending HTTP files..."
   rsync -az --info=progress2 ${HTTPDIR} ${RSYNC_HOST}:${RSYNC_DEST}/.
#   rsync -a  ${TEMPDIR}/boot/${UXNAME}.* ${RSYNC_HOST}:${RSYNC_DEST}/http/.
   echo "Sending the image files..."
   rsync -az --info=progress2 ${ISODIR} ${RSYNC_HOST}:${RSYNC_DEST}/.
   echo "Sending extra files..."
   rsync -az --info=progress2 ${BASEDIR}/extra/packages.* ${RSYNC_HOST}:${RSYNC_DEST}/.
   rsync -az --info=progress2 ${BASEDIR}/VERSION_INFO.txt ${RSYNC_HOST}:${RSYNC_DEST}/.
  fi
}
