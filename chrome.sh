#!/bin/sh
### My Google Google Chrome Updater ###

	cd /usr/share/chrome-update;
	
	is_file_exits(){
	local f="$1"
	[[ -f "$f" ]] && return 0 || return 1
	}

# Test for network conection per http://stackoverflow.com/a/14939373
# Not this just check if the interface is actually up. 
for interface in $(ls /sys/class/net/ | grep -v lo);
do
  if [[ $(cat /sys/class/net/$interface/carrier) = 1 ]]; then 
	if [[ `ip r | grep default` ]]; then
		OnLine=1; 
	fi
  fi	
done
if ! [ $OnLine ]; then echo "Not Online" > /dev/stderr && OnLine=0; exit; fi

if !(is_file_exits "$HOME/.chromeblock") then
	if (is_file_exits "$HOME/.chrome-update-history") then
		if [[ `date +"%j"` != `sed -ne '1p' "/home/\`whoami\`/.chrome-update-history"` ]]; then
			if OnLine=1; then
			echo -e "`date +'%j'`\n`curl "https://aur.archlinux.org/rpc.php?type=info&arg=37469" | sh json.sh | egrep '\["results","Version"\]' | cut -f2`" > "$HOME/.chrome-update-history";
			fi
		fi
	else
		if OnLine=1; then
		echo -e "`date +'%j'`\n`curl "https://aur.archlinux.org/rpc.php?type=info&arg=37469" | sh json.sh | egrep '\["results","Version"\]' | cut -f2`" > "$HOME/.chrome-update-history";
		fi
	fi


	if [[ *`sed -ne '2p' "$HOME/.chrome-update-history"`* !=  *`google-chrome --version | cut -d " " -f3`* &&  `sed -ne '2p' "$HOME/.chrome-update-history"` != "" ]]; then
		notify-send --icon=google-chrome "Update" "New Update is there."
		pkexec sh /usr/share/chrome-update/update_chrome.sh
	else
		google-chrome 
	fi
else
	notify-send --icon=edit-delete "Nice try, but we are not ready yet.";
	exo-open --launch WebBrowser "http://www.google.com/pacman/";
fi
