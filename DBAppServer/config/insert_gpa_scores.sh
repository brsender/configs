echo "**********************************************************************"
echo "  insert_gpa_scores.sh                                                "
echo "  insert gpa scores for mp, sptnr, and ptnr                           "
echo "**********************************************************************"

TODAY=`date '+%m%d%Y'`

echo "**********************************************************************"
echo "  Calculate equivalent credits                                        "
echo "**********************************************************************"

insert_eq_crdt.sh  > $DASHLOG/insert_eq_crdt.log 

echo "**********************************************************************"
echo "  Load the gpa scores                                                 "
echo "**********************************************************************"

insert_gpa_mp.sh   > $DASHLOG/insert_gpa_mp.log 

insert_gpa_sptn.sh > $DASHLOG/insert_gpa_sptn.log

insert_gpa_ptn.sh  > $DASHLOG/insert_gpa_ptn.log

echo Complete loading gpa scores: `date` >> $DASHLOG/timelog.txt

exit
