# python
cd /dst
UNINSTALLER="uninstall_python.sh"
echo '#!/bin/sh' > $UNINSTALLER
echo "cd /" >> $UNINSTALLER
echo -n "rm " >> $UNINSTALLER
find usr -type f -exec echo '"{}" ' \; | tr '\n' ' ' >> $UNINSTALLER
echo "" >> $UNINSTALLER
echo -n "rmdir " >> $UNINSTALLER
find usr -type d -exec echo '"{}" ' \; | sort -r | tr '\n' ' ' >> $UNINSTALLER # sort directories so e.g. /usr/bin is deleted before /usr
chmod +x $UNINSTALLER

# modules
cd /dst_mod
UNINSTALLER="uninstall_python_modules.sh"
echo '#!/bin/sh' > $UNINSTALLER
echo "cd /" >> $UNINSTALLER
echo -n "rm " >> $UNINSTALLER
find usr -type f -exec echo '"{}" ' \; | tr '\n' ' ' >> $UNINSTALLER
echo "" >> $UNINSTALLER
echo -n "rmdir " >> $UNINSTALLER
find usr -type d -exec echo '"{}" ' \; | sort -r | tr '\n' ' ' >> $UNINSTALLER # sort directories so e.g. /usr/bin is deleted before /usr
chmod +x $UNINSTALLER
