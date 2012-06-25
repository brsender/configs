HOST=`hostname`
case $HOST in
     ap00d03)
             APPSERVER=APAppServerMember3
             APPENV=CellIsolated1
             ;;
     ap00d04)
             APPSERVER=APAppServerMember4
             APPENV=CellIsolated1
             ;;
     ap00d01)
             APPSERVER=APAppServerMember1
             APPENV=CellIntegrated1
             ;;
     ap00d02)
             APPSERVER=APAppServerMember2
             APPENV=CellIntegrated1
             ;;
     ap00m01)
             APPSERVER=APAppServerMember1
             APPENV=CellModel1
             ;;
     ap00m02)
             APPSERVER=APAppServerMember2
             APPENV=CellModel1
             ;;
     ap00p01)
             APPSERVER=APAppServerMember1
             APPENV=CellProd1
             ;;
     ap00p02)
             APPSERVER=APAppServerMember2
             APPENV=CellProd1
             ;;
     *) /usr/bin/echo "Unknown host";;
esac

EAR_BASE_DIR=/prod/sys/WebSphere/AppServer7/profiles/${HOST}/installedApps/${APPENV}/AnnualPlan.ear
JSP_DIR=/prod/sys/WebSphere/AppServer7/profiles/${HOST}/temp/${HOST}/${APPSERVER}/AnnualPlan/APWebApp.war
LOGFILE=/apps7/APAppServer/deploy/AP_deployment.log

mailx -s 'GOLD: AP_deployment.sh running on '${HOST} bsender@newyorklife.com < ${LOGFILE}

/usr/bin/echo "`date` - AP_deployment.sh launched by `whoami` on $HOST" >> $LOGFILE

# Remove all compiled JSP files
if [ -d $JSP_DIR ] ; then
   /usr/bin/echo "`date` - Removing compiled JSP files in $JSP_DIR" >> $LOGFILE
   /usr/bin/rm -rf $JSP_DIR/*
fi

# Only run the ear explosion on the primary servers
case $HOST in
ap00d04|ap00d02|ap00m02|ap00p02)
     /usr/bin/echo "`date` - Running ear deployment on $HOST" >> $LOGFILE
     /prod/sys/WebSphere/opermenu/WAS7/deploy/AnnualPlan.sh
     ;;
esac

# Create symbolic links to configuration files
/usr/bin/echo "`date` - Setting symbolic links for configuration files on $HOST" >> $LOGFILE
cd /apps7/APAppServer/config

if [ -f *.properties ] ; then
   /usr/bin/rm -f *.properties
fi
if [ -f *.xml ] ; then
   /usr/bin/rm -f *.xml
fi

ln -s ${EAR_BASE_DIR}/config/annualplan.properties
ln -s ${EAR_BASE_DIR}/config/annualPlanNoAuthServletConfig.xml
ln -s ${EAR_BASE_DIR}/config/annualPlanServletConfig.xml
ln -s ${EAR_BASE_DIR}/config/app_config.properties
ln -s ${EAR_BASE_DIR}/config/com_nyl_annualplan_msg_en.properties

case $HOST in
     ap00d03|ap00d04)
            ln -s ${EAR_BASE_DIR}/config/annualplan_config.xml.iso annualplan_config.xml
            ln -s ${EAR_BASE_DIR}/config/com_nyl_annualplan_en.properties.iso com_nyl_annualplan_en.properties
            ;;
     ap00d01|ap00d02)
            ln -s ${EAR_BASE_DIR}/config/annualplan_config.xml.int annualplan_config.xml
            ln -s ${EAR_BASE_DIR}/config/com_nyl_annualplan_en.properties.int com_nyl_annualplan_en.properties
            ;;
     ap00m01|ap00m02)
            ln -s ${EAR_BASE_DIR}/config/annualplan_config.xml.mdl annualplan_config.xml
            ln -s ${EAR_BASE_DIR}/config/com_nyl_annualplan_en.properties.mdl com_nyl_annualplan_en.properties
            ;;
     ap00p01|ap00p02)
            ln -s ${EAR_BASE_DIR}/config/annualplan_config.xml.prod annualplan_config.xml
            ln -s ${EAR_BASE_DIR}/config/com_nyl_annualplan_en.properties.prod com_nyl_annualplan_en.properties
            ;;
     *) /usr/bin/echo "Unknown host";;
esac

if [ $? = 0 ] ; then 
   /usr/bin/echo "`date` - Symbolic link creation complete on $HOST" >> $LOGFILE
else
   /usr/bin/echo "`date` - Symbolic link creation failed with code: $? on $HOST" >> $LOGFILE
fi