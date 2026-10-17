b=$(ls -d /sys/class/power_supply/BAT* 2>/dev/null | head -n1)
[ -n "$b" ] || exit 0
c=$(cat "$b/capacity")
ac=$(cat /sys/class/power_supply/AC*/online 2>/dev/null | head -n1)
if [ "$ac" = 1 ]; then i=󰂄
elif [ "$c" -ge 90 ]; then i=󰁹
elif [ "$c" -ge 70 ]; then i=󰂀
elif [ "$c" -ge 50 ]; then i=󰁾
elif [ "$c" -ge 30 ]; then i=󰁼
elif [ "$c" -ge 10 ]; then i=󰁻
else i=󰂎
fi
echo "$i  $c%"
