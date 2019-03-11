#!/bin/sh

[ -f /tmp/email-listener.lock ] && exit 1
touch /tmp/email-listener.lock

function leave {
	/usr/bin/notify-send -u low "System" "Stopped emails listener"
	rm -f /tmp/email-listener.lock
}

function notify {
	from=`formail -X From: < $1`
	sub=`formail -X Subject: < $1`

	from=${from//</\(}
	from=${from//>/\)}
	from=${from//&/\.}
	sub=${sub//</\(}
	sub=${sub//>/\)}
	sub=${sub//&/\.}

	sub=${sub:0:200}
	from=${from:0:75}

	/usr/bin/notify-send -u normal "$from" "$sub"
}

trap leave EXIT
/usr/bin/notify-send -u low "System" "Starting emails listener"

while email_file=$(/usr/bin/inotifywait -q -e create -e moved_to --format '%w/%f' "$HOME/.mails/"*"/INBOX/new/")
do
	notify "$email_file"
done

