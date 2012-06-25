#!/usr/bin/sh

# There are 2 steps to complete to use the su migration script:
#	1.) Copy this script to same directory as your migration script and tar file on TV00P01 and rename su_<app>.sh
#	    Example: cp su_template.sh /softdist/stage/WASApp/CSAppServer/modl/su_CS.sh
#
#	2.) Once copied please fill in the variables section appropriately.
#
#       If you have any questions please contact Greg Koster at x2769 HO or Jeff Dong at x3645 HO.

# Define Variables (all are case sensitive)
# appName=<This is your app name, prefix only.  Ex. CSAppServer = CS>
# uid=<This is your WebSphere app uid. Ex. CSAppServer = cswas>
# guid=<This is the group the app uid belongs to. Ex. CSAppServer = cswas>
# migrationScript=<Enter the name of your migration script>

# MODIFY THIS SECTION ONLY!
appName=AP
uid=apwas
guid=apwas
migrationScript=AP_deployment.sh

# DO NOT MODIFY THIS SECTION
deploydir=/apps7/${appName}AppServer/deploy
cd $deploydir
chown $uid:$guid *
chmod 755 *
su $uid -c "sh $deploydir/$migrationScript"
chown -R $uid:$guid /apps7/${appName}AppServer
