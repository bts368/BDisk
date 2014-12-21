function yo_dj () {
  ARCH="${1}"
  echo "Building the actual .iso image. This may take a while."
  im_batman
  ISOFILENAME="${UXNAME}-${VERSION}.iso"
  if [[ "${MULTIARCH}" == "y" ]];
  then
    ISOFILENAME="${UXNAME}-${VERSION}-any.iso"
  else
    ISOFILENAME="${UXNAME}-${VERSION}-${ARCH}.iso"
  fi

  if [[ "${I_AM_A_RACECAR}" == "y" ]]; 
  then
    RACECAR_CHK='nice -n "-19" '
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
  APPEND ${UXNAME}_ram_64 -- ${UXNAME}_ram_32
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
ONTIMEOUT ${UXNAME}_ram_64
  
LABEL ${UXNAME}_ram_64
  MENU LABEL ^1) ${PNAME} (run from RAM) (Default)
  LINUX /boot/${UXNAME}.64.kern
  INITRD /boot/${UXNAME}.64.img
  APPEND copytoram archisobasedir=${DISTNAME} archisolabel=${DISTNAME}
  TEXT HELP
  64-bit, run from RAM
  ENDTEXT
  MENU DEFAULT

LABEL ${UXNAME}_64 
  MENU LABEL ^1) ${PNAME}
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
ONTIMEOUT ${UXNAME}_ram_32

## 32 BIT
LABEL ${UXNAME}_ram_32
  MENU LABEL ^1) ${PNAME} (run from RAM) (Default)
  LINUX /boot/${UXNAME}.32.kern
  INITRD /boot/${UXNAME}.32.img
  APPEND copytoram archisobasedir=${DISTNAME} archisolabel=${DISTNAME}
  TEXT HELP
  32-bit, run from RAM
  ENDTEXT
  MENU DEFAULT

LABEL ${UXNAME}_32 
  MENU LABEL ^2) ${PNAME}
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
ONTIMEOUT ${UXNAME}_ram_${ARCH}
  
LABEL ${UXNAME}_ram_${ARCH}
  MENU LABEL ^1) ${PNAME} (run from RAM) (Default)
  LINUX /boot/${UXNAME}.${ARCH}.kern
  INITRD /boot/${UXNAME}.${ARCH}.img
  APPEND copytoram archisobasedir=${DISTNAME} archisolabel=${DISTNAME}
  TEXT HELP
  ${ARCH}-bit, run from RAM
  ENDTEXT
  MENU DEFAULT

LABEL ${UXNAME}_${ARCH} 
  MENU LABEL ^1) ${PNAME}
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
-quiet \
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


  #isohybrid ${ISOFILENAME}
  cd ${ISODIR}
  ${RACECAR_CHK}sha256sum ${ISOFILENAME} > ${ISOFILENAME}.sha256
  cd ..
  echo "ISO generated; size is $(ls -lh ${ISODIR}/${ISOFILENAME} | awk '{print $5}')."
  echo "SHA256 sum is: $(awk '{print $1}' ${ISODIR}/${ISOFILENAME}.sha256)"
  echo "You can find it at ${ISODIR}/${ISOFILENAME}"
  #rm -rf ${TEMPDIR}/*

  # are we rsyncing?
  if [ -n "${RSYNC_HOST}" ];
  then
   rsync -a ${TFTPDIR}/. ${RSYNC_HOST}:${RSYNC_DEST}/tftpboot/.
   rsync -a ${HTTPDIR}/. ${RSYNC_HOST}:${RSYNC_DEST}/http/.
#   rsync -a  ${TEMPDIR}/boot/${UXNAME}.* ${RSYNC_HOST}:${RSYNC_DEST}/http/.
   rsync -a ${ISODIR}/. ${RSYNC_HOST}:${RSYNC_DEST}/iso/.
   rsync -a ${ROOTDIR}/extra/. ${RSYNC_HOST}:${RSYNC_DEST}/extra/.
  fi
}