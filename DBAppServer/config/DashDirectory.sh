HOST=`hostname`
case $HOST in
ap00d03|ap00d04) APPSERVER=CellIsolated1;;
ap00d01|ap00d02) APPSERVER=CellIntegrated1;;
ap00m03|ap00m04) APPSERVER=CellModel2;;
ap00p03|ap00p04) APPSERVER=CellProd2;;
*) /usr/bin/echo "Unknown host";;
esac

EAR_DIR=/prod/sys/WebSphere/AppServer6/profiles/${HOST}/installedApps/${APPSERVER}/Dashboard.ear
cd ${EAR_DIR}
