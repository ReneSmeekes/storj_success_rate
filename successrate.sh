#!/usr/bin/env bash
#A StorJ node monitor script: Initial version by turbostorjdsk / KernelPanick, adapted by BrightSilence, original grep statements by Alexey

# assumes your docker container is named 'storagenode'. If not, pass it as the first argument, e.g.:
# bash successrate.sh mynodename
DOCKER_NODE_NAME="${1:-storagenode}"

LOG_CACHE=$(mktemp -p /dev/shm/)
LOG_SOURCE="docker logs $DOCKER_NODE_NAME"
#Log line can be edited using cat for SNO's who wrote their log to a file.
#LOG_SOURCE="cat /volume1/storj/v3/data/node.log"

# Cache log
$LOG_SOURCE > $LOG_CACHE 2>&1

#Node Success Rates

echo -e "\e[96m========== AUDIT ============= \e[0m"
#count of successful audits
audit_success=$(cat $LOG_CACHE | grep GET_AUDIT | grep downloaded -c)
echo -e "\e[92mSuccessful:           $audit_success \e[0m"
#count of recoverable failed audits
audit_failed_warn=$(cat $LOG_CACHE | grep GET_AUDIT | grep failed | grep -v open -c)
echo -e "\e[33mRecoverable failed:   $audit_failed_warn \e[0m"
#count of unrecoverable failed audits
audit_failed_crit=$(cat $LOG_CACHE | grep GET_AUDIT | grep failed | grep open -c)
echo -e "\e[91mUnrecoverable failed: $audit_failed_crit \e[0m"
#Ratio of Successful to Failed Audits
if [ $(($audit_success+$audit_failed_crit+$audit_failed_warn)) -ge 1 ]
then
	audit_success_min=$(printf '%.3f\n' $(echo -e "$audit_success $audit_failed_crit $audit_failed_warn" | awk '{print ( $1 / ( $1 + $2 + $3 )) * 100 }'))%
else
	audit_success_min=0.000%
fi
echo -e "Success Rate Min:     $audit_success_min"
if [ $(($audit_success+$audit_failed_crit)) -ge 1 ]
then
	audit_success_max=$(printf '%.3f\n' $(echo -e "$audit_success $audit_failed_crit" | awk '{print ( $1 / ( $1 + $2 )) * 100 }'))%
else
	audit_success_max=0.000%
fi
echo -e "Success Rate Max:     $audit_success_max"

echo -e "\e[96m========== DOWNLOAD ========== \e[0m"
#count of successful downloads
dl_success=$(cat $LOG_CACHE | grep '"GET"' | grep downloaded -c)
echo -e "\e[92mSuccessful:           $dl_success \e[0m"
#Failed Downloads from your node
dl_failed=$(cat $LOG_CACHE | grep '"GET"' | grep failed -c)
echo -e "\e[33mFailed:               $dl_failed \e[0m"
#Ratio of Failed Downloads
if [ $(($dl_success+$dl_failed)) -ge 1 ]
then
	dl_ratio=$(printf '%.3f\n' $(echo -e "$dl_success $dl_failed" | awk '{print ( $1 / ( $1 + $2 )) * 100 }'))%
else
	dl_ratio=0.000%
fi
echo -e "Success Rate:         $dl_ratio"

echo -e "\e[96m========== UPLOAD ============ \e[0m"
#count of successful uploads to your node
put_success=$(cat $LOG_CACHE | grep '"PUT"' | grep uploaded -c)
echo -e "\e[92mSuccessful:           $put_success \e[0m"
#count of rejected uploads to your node
put_rejected=$(cat $LOG_CACHE | grep rejected | grep upload -c)
echo -e "\e[33mRejected:             $put_rejected \e[0m"
#count of failed uploads to your node
put_failed=$(cat $LOG_CACHE | grep '"PUT"' | grep failed -c)
echo -e "\e[33mFailed:               $put_failed \e[0m"
#Ratio of Uploads
if [ $(($put_success+$put_rejected)) -ge 1 ]
then
	put_accept_ratio=$(printf '%.3f\n' $(echo -e "$put_success $put_rejected" | awk '{print ( $1 / ( $1 + $2 )) * 100 }'))%
else
	put_accept_ratio=0.000%
fi
echo -e "Acceptance Rate:      $put_accept_ratio"
if [ $(($put_success+$put_failed)) -ge 1 ]
then
	put_ratio=$(printf '%.3f\n' $(echo -e "$put_success $put_failed" | awk '{print ( $1 / ( $1 + $2 )) * 100 }'))%
else
	put_ratio=0.000%
fi
echo -e "Success Rate:         $put_ratio"

echo -e "\e[96m========== REPAIR DOWNLOAD === \e[0m"
#count of successful downloads of pieces for repair process
get_repair_success=$(cat $LOG_CACHE | grep GET_REPAIR | grep downloaded -c)
echo -e "\e[92mSuccessful:           $get_repair_success \e[0m"
#count of failed downloads of pieces for repair process
get_repair_failed=$(cat $LOG_CACHE | grep GET_REPAIR | grep failed -c)
echo -e "\e[33mFailed:               $get_repair_failed \e[0m"
#Ratio of GET_REPAIR
if [ $(($get_repair_success+$get_repair_failed)) -ge 1 ]
then
	get_repair_ratio=$(printf '%.3f\n' $(echo -e "$get_repair_success $get_repair_failed" | awk '{print ( $1 / ( $1 + $2 )) * 100 }'))%
else
	get_repair_ratio=0.000%
fi
echo -e "Success Rate:         $get_repair_ratio"

echo -e "\e[96m========== REPAIR UPLOAD ===== \e[0m"
#count of successful uploads of repaired pieces
put_repair_success=$(cat $LOG_CACHE | grep PUT_REPAIR | grep uploaded -c)
echo -e "\e[92mSuccessful:           $put_repair_success \e[0m"
#count of failed uploads repaired pieces
put_repair_failed=$(cat $LOG_CACHE | grep PUT_REPAIR | grep failed -c)
echo -e "\e[33mFailed:               $put_repair_failed \e[0m"
#Ratio of PUT_REPAIR
if [ $(($put_repair_success+$put_repair_failed)) -ge 1 ]
then
	put_repair_ratio=$(printf '%.3f\n' $(echo -e "$put_repair_success $put_repair_failed" | awk '{print ( $1 / ( $1 + $2 )) * 100 }'))%
else
	put_repair_ratio=0.000%
fi
echo -e "Success Rate:         $put_repair_ratio"

rm $LOG_CACHE