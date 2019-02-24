#-----------------------------------------------------------------------------------------------------------------------#
# Script Name       : Main.sh
# Author            : Balaji S
# Date              : 22/JAN/2016
# Description       :
# Usage             : sh -x Main.sh
#-----------------------------------------------------------------------------------------------------------------------#

#-----------------------------------------------------------------------------------------------------------------------#
### Declaring variables
#-----------------------------------------------------------------------------------------------------------------------#

Scriptpath="/home/hadoop/Documents/Bigdata"
Pigbinpath="/data/pig/bin"
Hivebinpath="/data/hive/bin"


HDFSSrcFilepath="/SrcFile"
SrcFilepath="/home/hadoop/Documents/SrcFile"

#-----------------------------------------------------------------------------------------------------------------------#
### Hadoop Process running check
#-----------------------------------------------------------------------------------------------------------------------#

NumberOfJobs=`jps | wc -l`

if [ $NumberOfJobs -lt 5 ]
then
echo "1. JPS are not running, Number of jobs : $NumberOfJobs"
exit 1
else
echo "JPS Check is completed"
fi

#-----------------------------------------------------------------------------------------------------------------------#
### Delete & Uploading the Source file in hadoop 
### Removing the old Pig file in hadoop #-----------------------------------------------------------------------------------------------------------------------#

hdfs dfs -rm -r $HDFSSrcFilepath

hdfs dfs -mkdir $HDFSSrcFilepath
hdfs dfs -put ${SrcFilepath}/* $HDFSSrcFilepath/

hdfs dfs -rm -r '/DOMAIN'
hdfs dfs -rm -r '/WORDS'
hdfs dfs -rm -r '/KEYWORDS'


# One time Execution
#hdfs dfs -mkdir CONFIRMED_DIM
#hdfs dfs -put /home/hadoop/Documents/CONFIRMED_DIM/* CONFIRMED_DIM/


echo "1. File Removal & Uploading Task Completed"


#-----------------------------------------------------------------------------------------------------------------------#
### Triggering the Pig script
#-----------------------------------------------------------------------------------------------------------------------#

cd /home/hadoop/Documents/Piglogs

${Pigbinpath}/pig -f ${Scriptpath}/Cleansing.pig

OUT=$?

if [ $OUT -ne 0 ]
then
echo "2. Pig Script Failed, Exit Code : $OUT"
exit 1
else
echo "2. Pig Script Completed"
fi

#-----------------------------------------------------------------------------------------------------------------------#
### Triggering the Hive script
#-----------------------------------------------------------------------------------------------------------------------#

${Hivebinpath}/hive -f ${Scriptpath}/Reporting.hive

OUT=$?

if [ $OUT -ne 0 ]
then
echo "3. Hive Script Failed, Exit Code : $OUT"
exit 1
else
echo "3. Hive Script Completed"
fi

