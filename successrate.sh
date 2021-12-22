#!/usr/bin/env bash
#A StorJ node monitor script: Contains code contributed by: BrightSilence, turbostorjdsk / KernelPanick, Alexey

LOG_SOURCE="$*"

if [ -e "${1}" ]
then
	# the first argument is passed and it's an existing log file
	if [[ "${LOG_SOURCE}" == *.gz ]]
        then
          LOG="zcat ${LOG_SOURCE}"
        else
	  LOG="cat ${LOG_SOURCE}"
        fi
else
	# assumes your docker container is named 'storagenode'. If not, pass it as the first argument, e.g.:
	# bash successrate.sh mynodename
	DOCKER_NODE_NAME="${*:-storagenode}"
	LOG="docker logs $DOCKER_NODE_NAME"
fi

PRINTF=$(which printf)

#Node Success Rates
echo -e "\e[96m========== AUDIT ============== \e[0m"
#count of successful audits
audit_success=$($LOG 2>&1 | grep GET_AUDIT | grep downloaded -c)
#count of recoverable failed audits
audit_failed_warn=$($LOG 2>&1 | grep GET_AUDIT | grep failed | grep -v exist -c)
#count of unrecoverable failed audits
audit_failed_crit=$($LOG 2>&1 | grep GET_AUDIT | grep failed | grep exist -c)
#Ratio of Successful to Failed Audits
if [ $(($audit_success+$audit_failed_crit+$audit_failed_warn)) -ge 1 ]
then
	audit_successrate=$($PRINTF '%.3f\n' $(echo -e "$audit_success $audit_failed_crit $audit_failed_warn" | awk '{print ( $1 / ( $1 + $2 + $3 )) * 100 }'))%
else
	audit_successrate=0.000%
fi
if [ $(($audit_success+$audit_failed_crit+$audit_failed_warn)) -ge 1 ]
then
	audit_recfailrate=$($PRINTF '%.3f\n' $(echo -e "$audit_failed_warn $audit_success $audit_failed_crit" | awk '{print ( $1 / ( $1 + $2 + $3 )) * 100 }'))%
else
	audit_recfailrate=0.000%
fi
if [ $(($audit_success+$audit_failed_crit+$audit_failed_warn)) -ge 1 ]
then
	audit_failrate=$($PRINTF '%.3f\n' $(echo -e "$audit_failed_crit $audit_failed_warn $audit_success" | awk '{print ( $1 / ( $1 + $2 + $3 )) * 100 }'))%
else
	audit_failrate=0.000%
fi
echo -e "\e[91mCritically failed:     $audit_failed_crit \e[0m"
echo -e "Critical Fail Rate:    $audit_failrate"
echo -e "\e[33mRecoverable failed:    $audit_failed_warn \e[0m"
echo -e "Recoverable Fail Rate: $audit_recfailrate"
echo -e "\e[92mSuccessful:            $audit_success \e[0m"
echo -e "Success Rate:          $audit_successrate"

echo -e "\e[96m========== DOWNLOAD =========== \e[0m"
#count of successful downloads
dl_success=$($LOG 2>&1 | grep '"GET"' | grep downloaded -c)
#canceled Downloads from your node
dl_canceled=$($LOG 2>&1 | grep '"GET"' | grep 'download canceled' -c)
#Failed Downloads from your node
dl_failed=$($LOG 2>&1 | grep '"GET"' | grep 'download failed' -c)
#Ratio of canceled Downloads
if [ $(($dl_success+$dl_failed+$dl_canceled)) -ge 1 ]
then
        dl_canratio=$($PRINTF '%.3f\n' $(echo -e "$dl_canceled $dl_success $dl_failed" | awk '{print ( $1 / ( $1 + $2 + $3 )) * 100 }'))%
else
	dl_canratio=0.000%
fi
#Ratio of Failed Downloads
if [ $(($dl_success+$dl_failed+$dl_canceled)) -ge 1 ]
then
	dl_failratio=$($PRINTF '%.3f\n' $(echo -e "$dl_failed $dl_success $dl_canceled" | awk '{print ( $1 / ( $1 + $2 + $3 )) * 100 }'))%
else
	dl_failratio=0.000%
fi
#Ratio of Successful Downloads
if [ $(($dl_success+$dl_failed+$dl_canceled)) -ge 1 ]
then
	dl_ratio=$($PRINTF '%.3f\n' $(echo -e "$dl_success $dl_failed $dl_canceled" | awk '{print ( $1 / ( $1 + $2 + $3 )) * 100 }'))%
else
	dl_ratio=0.000%
fi
echo -e "\e[91mFailed:                $dl_failed \e[0m"
echo -e "Fail Rate:             $dl_failratio"
echo -e "\e[33mCanceled:              $dl_canceled \e[0m"
echo -e "Cancel Rate:           $dl_canratio"
echo -e "\e[92mSuccessful:            $dl_success \e[0m"
echo -e "Success Rate:          $dl_ratio"

echo -e "\e[96m========== UPLOAD ============= \e[0m"
#count of successful uploads to your node
put_success=$($LOG 2>&1 | grep '"PUT"' | grep uploaded -c)
#count of rejected uploads to your node
put_rejected=$($LOG 2>&1 | grep 'upload rejected' -c)
#count of canceled uploads to your node
put_canceled=$($LOG 2>&1 | grep '"PUT"' | grep 'upload canceled' -c)
#count of failed uploads to your node
put_failed=$($LOG 2>&1 | grep '"PUT"' | grep 'upload failed' -c)
#Ratio of Rejections
if [ $(($put_success+$put_rejected+$put_canceled+$put_failed)) -ge 1 ]
then
	put_accept_ratio=$($PRINTF '%.3f\n' $(echo -e "$put_rejected $put_success $put_canceled $put_failed" | awk '{print ( ($2 + $3 + $4) / ( $1 + $2 + $3 + $4 )) * 100 }'))%
else
	put_accept_ratio=0.000%
fi
#Ratio of Failed
if [ $(($put_success+$put_rejected+$put_canceled+$put_failed)) -ge 1 ]
then
	put_fail_ratio=$($PRINTF '%.3f\n' $(echo -e "$put_failed $put_success $put_canceled" | awk '{print ( $1 / ( $1 + $2 + $3 )) * 100 }'))%
else
	put_fail_ratio=0.000%
fi
#Ratio of canceled
if [ $(($put_success+$put_rejected+$put_canceled+$put_failed)) -ge 1 ]
then
	put_cancel_ratio=$($PRINTF '%.3f\n' $(echo -e "$put_canceled $put_failed $put_success" | awk '{print ( $1 / ( $1 + $2 + $3 )) * 100 }'))%
else
	put_cancel_ratio=0.000%
fi
#Ratio of Success
if [ $(($put_success+$put_rejected+$put_canceled+$put_failed)) -ge 1 ]
then
	put_ratio=$($PRINTF '%.3f\n' $(echo -e "$put_success $put_failed $put_canceled" | awk '{print ( $1 / ( $1 + $2 + $3 )) * 100 }'))%
else
	put_ratio=0.000%
fi
echo -e "\e[33mRejected:              $put_rejected \e[0m"
echo -e "Acceptance Rate:       $put_accept_ratio"
echo -e "\e[96m---------- accepted ----------- \e[0m"
echo -e "\e[91mFailed:                $put_failed \e[0m"
echo -e "Fail Rate:             $put_fail_ratio"
echo -e "\e[33mCanceled:              $put_canceled \e[0m"
echo -e "Cancel Rate:           $put_cancel_ratio"
echo -e "\e[92mSuccessful:            $put_success \e[0m"
echo -e "Success Rate:          $put_ratio"

echo -e "\e[96m========== REPAIR DOWNLOAD ==== \e[0m"
#count of successful downloads of pieces for repair process
get_repair_success=$($LOG 2>&1 | grep GET_REPAIR | grep downloaded -c)
#count of failed downloads of pieces for repair process
get_repair_failed=$($LOG 2>&1 | grep GET_REPAIR | grep 'download failed' -c)
#count of canceled downloads of pieces for repair process
get_repair_canceled=$($LOG 2>&1 | grep GET_REPAIR | grep 'download canceled' -c)
#Ratio of Fail GET_REPAIR
if [ $(($get_repair_success+$get_repair_failed+$get_repair_canceled)) -ge 1 ]
then
	get_repair_failratio=$($PRINTF '%.3f\n' $(echo -e "$get_repair_failed $get_repair_success $get_repair_canceled" | awk '{print ( $1 / ( $1 + $2 + $3 )) * 100 }'))%
else
	get_repair_failratio=0.000%
fi
#Ratio of Cancel GET_REPAIR
if [ $(($get_repair_success+$get_repair_failed+$get_repair_canceled)) -ge 1 ]
then
	get_repair_canratio=$($PRINTF '%.3f\n' $(echo -e "$get_repair_canceled $get_repair_success $get_repair_failed" | awk '{print ( $1 / ( $1 + $2 + $3 )) * 100 }'))%
else
	get_repair_canratio=0.000%
fi
#Ratio of Success GET_REPAIR
if [ $(($get_repair_success+$get_repair_failed+$get_repair_canceled)) -ge 1 ]
then
	get_repair_ratio=$($PRINTF '%.3f\n' $(echo -e "$get_repair_success $get_repair_failed $get_repair_canceled" | awk '{print ( $1 / ( $1 + $2 + $3 )) * 100 }'))%
else
	get_repair_ratio=0.000%
fi
echo -e "\e[91mFailed:                $get_repair_failed \e[0m"
echo -e "Fail Rate:             $get_repair_failratio"
echo -e "\e[33mCanceled:              $get_repair_canceled \e[0m"
echo -e "Cancel Rate:           $get_repair_canratio"
echo -e "\e[92mSuccessful:            $get_repair_success \e[0m"
echo -e "Success Rate:          $get_repair_ratio"

echo -e "\e[96m========== REPAIR UPLOAD ====== \e[0m"
#count of successful uploads of repaired pieces
put_repair_success=$($LOG 2>&1 | grep PUT_REPAIR | grep uploaded -c)
#count of canceled uploads repaired pieces
put_repair_canceled=$($LOG 2>&1 | grep PUT_REPAIR | grep 'upload canceled' -c)
#count of failed uploads repaired pieces
put_repair_failed=$($LOG 2>&1 | grep PUT_REPAIR | grep 'upload failed' -c)
#Ratio of Fail PUT_REPAIR
if [ $(($put_repair_success+$put_repair_failed+$put_repair_canceled)) -ge 1 ]
then
	put_repair_failratio=$($PRINTF '%.3f\n' $(echo -e "$put_repair_failed $put_repair_success $put_repair_canceled" | awk '{print ( $1 / ( $1 + $2 + $3 )) * 100 }'))%
else
	put_repair_failratio=0.000%
fi
#Ratio of Cancel PUT_REPAIR
if [ $(($put_repair_success+$put_repair_failed+$put_repair_canceled)) -ge 1 ]
then
	put_repair_canratio=$($PRINTF '%.3f\n' $(echo -e "$put_repair_canceled $put_repair_success $put_repair_failed" | awk '{print ( $1 / ( $1 + $2 + $3 )) * 100 }'))%
else
	put_repair_canratio=0.000%
fi
#Ratio of Success PUT_REPAIR
if [ $(($put_repair_success+$put_repair_failed+$put_repair_canceled)) -ge 1 ]
then
	put_repair_ratio=$($PRINTF '%.3f\n' $(echo -e "$put_repair_success $put_repair_failed $put_repair_canceled" | awk '{print ( $1 / ( $1 + $2 + $3 )) * 100 }'))%
else
	put_repair_ratio=0.000%
fi
echo -e "\e[91mFailed:                $put_repair_failed \e[0m"
echo -e "Fail Rate:             $put_repair_failratio"
echo -e "\e[33mCanceled:              $put_repair_canceled \e[0m"
echo -e "Cancel Rate:           $put_repair_canratio"
echo -e "\e[92mSuccessful:            $put_repair_success \e[0m"
echo -e "Success Rate:          $put_repair_ratio"

echo -e "\e[96m========== DELETE ============= \e[0m"
#count of successful deletes
delete_success=$($LOG 2>&1 | grep -E 'deleted|delete piece' -c)
#count of failed deletes
delete_failed=$($LOG 2>&1 | grep 'delete failed' -c)
#Ratio of Fail delete
if [ $(($delete_success+$delete_failed)) -ge 1 ]
then
	delete_failratio=$($PRINTF '%.3f\n' $(echo -e "$delete_failed $delete_success" | awk '{print ( $1 / ( $1 + $2 )) * 100 }'))%
else
	delete_failratio=0.000%
fi
#Ratio of Success delete
if [ $(($delete_success+$delete_failed)) -ge 1 ]
then
	delete_ratio=$($PRINTF '%.3f\n' $(echo -e "$delete_success $delete_failed" | awk '{print ( $1 / ( $1 + $2 )) * 100 }'))%
else
	delete_ratio=0.000%
fi
echo -e "\e[33mFailed:                $delete_failed \e[0m"
echo -e "Fail Rate:             $delete_failratio"
echo -e "\e[92mSuccessful:            $delete_success \e[0m"
echo -e "Success Rate:          $delete_ratio"
