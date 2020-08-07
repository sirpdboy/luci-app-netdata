#!/bin/sh
# set -x
#https://github.com/sirpdboy/luci-app-netdata

ND_DIR=/usr/share/netdata
TMP_DIR=/tmp/netdata
LOGFILE="/var/log/netdata.log"

config_t_get() {
	local index=0
	[ -n "$4" ] && index=$4
	local ret=$(uci get $CONFIG.@$1[$index].$2 2>/dev/null)
	echo ${ret:=$3}
}

limit_log() {
	local log=$1
	[ ! -f "$log" ] && return
	local sc=100
	[ -n "$2" ] && sc=$2
	local count=$(grep -c "" $log)
	if [ $count -gt $sc ];then
		let count=count-$sc
		sed -i "1,$count d" $log
	fi
}

init_env() {
	rm -rf "$TMP_DIR"
	mkdir -p "$TMP_DIR"
}

restart_netdata() {
	/etc/init.d/netdata restart
}

update_cn() {
	echo $(date "+%F %T"): ---------升级中文版---------- >>$LOGFILE
	wget  -q -O /etc/netdata/netdata.conf  https://raw.githubusercontent.com/siropboy/mypackages/master/luci-app-netdata/root/etc/netdata/netdata.conf
	wget  -q -O $ND_DIR/web/dashboard_info.js  https://raw.githubusercontent.com/siropboy/mypackages/master/luci-app-netdata/root/usr/share/netdate/web/dashboard.js
	wget -q -O $ND_DIR/web/dashboard.js  https://raw.githubusercontent.com/siropboy/mypackages/master/luci-app-netdata/root/usr/share/netdate/web/dashboard.js
	wget -q -O $ND_DIR/web/main.js  https://raw.githubusercontent.com/siropboy/mypackages/master/luci-app-netdata/root/usr/share/netdate/web/main.js
	wget -q -O $ND_DIR/web/index.html  https://raw.githubusercontent.com/siropboy/mypackages/master/luci-app-netdata/root/usr/share/netdate/web/index.html
	echo $(date "+%F %T"): ---------更新成功！------- >>$LOGFILE
    RESTART_netdata=true

}


# main process
init_env
limit_log $LOGFILE

# update_cn
update_cn

if [ $RESTART_netdata ]; then
	restart_netdata
	echo $(date "+%F %T"): 重启netdata进程 >>$LOGFILE
fi
init_env

