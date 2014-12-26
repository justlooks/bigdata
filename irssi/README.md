leave channle
/wc

check setting

/set
/set activity   # check option with activity string
/set timestamp_format %H:%M:%S                 # change option value (after change use /save to save it, it will write to ~/.issri/config)

check configured network and server
/network list
/server list

change irssi theme
download theme script,and put it in ~/.irssi dir
wget -P ~/.irssi https://raw.githubusercontent.com/msparks/irssiscripts/master/themes/fear2.theme
change new theme ,and save it
/set theme fear2
/save

list the nickname in a channel
/names or /n

check the topic
/topic or /t

check the user info
/whois  or /wi

query window with a user
/query or /q

send a message to a user
/msg or /m

check window info
/window

---------------------------------

search for useful script in scripts.irssi.org ,put it in ~/.irssi/scripts ,and type /run <scriptname> to run it,link it in ~/.irssi/scripts/autorun,to let it autorun

whit is  query windows ??
