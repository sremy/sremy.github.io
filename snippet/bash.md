## Bash useful commands

### Bash customization & Colors

The blue color is often not readable on dark terminal, we need to tell it to vim:
```bash
echo -e "set nocompatible\nsyntax on\nset background=dark" >> ~/.vimrc
```
For ls colors, we can init the colors configuration file and replace dark blue with cyan:
```bash
dircolors -p | sed 's/;34/;36/g' | sed 's/LINK 01;36/LINK 04;36/g' > ~/.dircolors
```

Colors in .bashrc
For Debian .bashrc skeleton, see <https://bazaar.launchpad.net/~doko/+junk/pkg-bash-debian/view/head:/skel.bashrc>
```bash
# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi
# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
```

### Useful functions

Create directory and jump inside
```bash
md () { [ $# = 1 ] && mkdir -p "$@" && cd "$@" || echo "Error - no directory passed!"; }
```

Make bash your default shell if you don't have admin rights:
```bash
$ chsh
```
Or put following lines at the end of `.profile` file if access rights are centralized (kerberos, LDAP)
```bash
if [ $SHELL == "/bin/ksh" ]
then
  setenv SHELL /bin/bash
  exec "$SHELL" --login
  source /etc/bashrc
fi
```

Bash startup file:
```bash
bash --rcfile <file>  # run custom file at login instead of ~/.bashrc
bash --rcfile <( echo "source /etc/bashrc; date; PS1='\[\e]0;\u@\h: \w\a\]\t \[\e[01;32m\]\u@\h\[\e[00m\]:\[\e[01;34m\]\w \$\[\e[00m\] ' " )
```

Customize motd, message displayed at login

Create a new script in the directory `/etc/profile.d/` or execute it from ~/.bashrc,
Example: [motd.sh](https://github.com/sremy/scripts/raw/master/linux/motd.sh)

Bash Prompt
```bash
PS1="\[\e]0;\u@\h: \w\a\]\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w \$\[\033[00m\] "
PS1="\[\e]0;\u@\h: \w\a\]\t \[\e[01;32m\]\u@\h\[\e[00m\]:\[\e[01;34m\]\w \$\[\e[00m\] "

$ echo -en "\e" | hexdump -dC
0000000   00027
$ echo -en "\033" | hexdump -dC
0000000   00027
```
> 27 	033 	1B 	0011011 	ESC 	Escape (échappement)

Ordinal and character functions
```bash
chr() { printf \\$(printf '%03o' $1); }
ord() { printf '%d' "'$1"; }
```

Print characters table between 32 and 128 decimal code
```bash
for n in {32..128}
do
    if [ "$n" -eq "32" ]; then printf "dd oo hx c\n"; fi;
    printf "%d %o %x \\$(printf '%03o' $n)\n" $n $n $n;
done
```

### Built-in functions

Loop on integer range and compute arithmetic formulas
```bash
for n in {1..100}
do
    echo $n $((n*n)) $[n*(n+1)/2]
done
```

Expression-based substring deletion

- Form # : ${variable#delete_shortest_from_front}
- Form ##: ${variable##delete_longest_from_front}
- Form % : ${variable%delete_shortest_from_back}
- Form %%: ${variable%%delete_longest_from_back}
```bash
$ variable="This is a test string"
$ echo "${variable#* }"
is a test string
$ echo "${variable##* }"
string
$ echo "${variable% *}"
This is a test
$ echo "${variable%% *}"
This
```
String Length
```bash
$ echo ${#variable}
21
```

Parameter Substitution
<http://www.tldp.org/LDP/abs/html/parameter-substitution.html>

### Date

Print current date/time with custom format
```bash
date +"%y%m%d-%H%M"
date +"%y%m%d-%H%M%S"
date +"%Y-%m-%d_%H-%M-%S"
date -u # UTC
```

System Timezone
```bash
$ cat /etc/timezone
Europe/Paris
```

### SSH

Create a Ed25519 key pair in ~/.ssh/
```
$ ssh-keygen -t ed25519
```
Send the public key to the remote server, to make it accessible by key
```
$ ssh-copy-id login@remote.org # sends the public key in remote ~/.ssh/authorized_keys
$ ssh-copy-id -i ~/.ssh/id_ed25519.pub -p 2222 login@remote.org
```
Be sure to have authorized_keys only readable and writable by the owner
Especially, .ssh and authorized_keys must not be writable by other.
```
mkdir ~/.ssh
chmod 700 ~/.ssh
cat ~/id_ed25519.pub >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
```

To extract the public key from a private key:
```bash
$ ssh-keygen -yf .ssh/id_ed25519
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHCrIlv9jr3P8zKIjizsiozEgHjeuFnmwledmpqHyknN
$ cat .ssh/id_ed25519.pub
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHCrIlv9jr3P8zKIjizsiozEgHjeuFnmwledmpqHyknN churchkey
```
SSH host keys
```
$ ssh-keyscan 192.168.0.15         # from client
$ cat /etc/ssh/ssh_host_*key.pub   # from server
```
Key fingerprint: MD5 displayed in hexadecimal, SHA-1 and SHA-256 in base64
```bash
$ ssh-keygen -lf .ssh/id_ed25519.pub  # by default shows SHA-256 hash
$ ssh-keygen -lf .ssh/authorized_keys

# Fingerprints can be hashed in MD5 (Hexa) or SHA1/SHA256 (Base64) with -E option
$ ssh-keygen -lf ~/.ssh/id_ed25519.pub -E md5                  # MD5 Hexa
$ awk '{print $2}' ~/.ssh/id_ed25519.pub | base64 -d | md5sum  # MD5 Hexa, same result manually
```

Send a file to a list of servers and execute commands remotely
```bash
echo -e "192.168.0.15\n192.168.0.31" > servers.txt
for s in $(cat servers.txt)
do
    echo "## $s ##"
    scp myfile user@$s:
    ssh user@$s ls -l myfile
done
```

## Files
Sort files recursively
- Latest files at the top
```bash
function findLatest () {
    find -L $1 ! -type d -printf "%T@ %Tc %11s %p\n" | sort -k 1nr | sed 's/^[^ ]* //' | less
}
```
- Biggest files at the top
```bash
find -L . ! -type d -printf "%12s %p\n" | sort -r -n -k1
find -L . ! -type d -printf "%Ta %Td-%Tb-%TY %TT %12s %p\n" | sort -r -n -k4  # With change time
find -L . ! -type d -ls | sort -r -n -k7
```

### CSV and AWK
- Count the number of fields in the first line:
```bash
head -1 <file> | awk -F'[;|\t]' '{print NF}'
```
- For csv.gz files:
```bash
zcat <file.gz> | head -1 | awk -F'[;|\t]' '{print NF}'
```

- Print columns count for each line:
```bash
awk -F'[;|\t]' '{print NF}' <file> | sort | uniq
```
- For csv.gz files:
```bash
zcat <file.gz> | awk -F'[;|\t]' '{print NF}' | sort | uniq
```

- Print lines containing exactly \<N\> columns:
```bash
awk -F"\t" 'NF == <N> {print $0}' <file>
```

- Identify each column by showing its position
```bash
awk -F'[;|\t]' '{for (i=1; i<=NF; i++) printf("[%d:%s] ", i, $i); print ""}' <file> | head -1
zcat <file.gz> | awk -F'[;|\t]' '{for (i=1; i<=NF; i++) printf("[%d:%s] ", i, $i); print ""}' | head -1
```

- Extract column number i:
```bash
awk -F"\t" '{print ($i)}' <file>
awk -F"\t" '{print (FILENAME ": " $i)}' <files>
zcat <file.gz> | awk -F"\t" '{print ($i)}'
zcat <file.gz> | cut -fi -d'|'
zcat <file.gz> | cut -fi   # by default separator is tab
```

- Extract distinct 10th field of CSV file :
```bash
awk -F"[|\t]" '{print($10 " " FILENAME)}' ~/folder/*.csv | uniq
```

- Extract pattern of 12 digits from filename
```bash
ls ~/folder/*pattern* | egrep -o '_[0-9]{12}_' | sort | uniq
```

Select lines on a field criteria
```bash
awk 'BEGIN {FS="|"} $10 ~ "motif.*" {print $0}' <file>
```

Extract duplicate values in columns 5:
```bash
awk 'c=tab[$5] {print c"\n"$0;} {tab[$5]=$0;}' <file>
awk '$5 in a{print a[$5]; print} {a[$5]=$0}'
```

Count after group by on a column:
- avec header:
```bash
awk -F"\t" 'NR>1{count[$1]++} END{for (a in count) print a, count[a]}' <file>
```
- sans header:
```bash
awk -F"\t" '{count[$1]++} END{for (a in count) print a, count[a]}' <file>
zcat <file.gz> | awk -F"\t" '{count[$1]++} END{for (a in count) printf "%-20s %20s\n", a, count[a]}' | sort
```

- Filter, Group by, Count and Print in apparition order
```bash
awk -F'[\\ ] ' '$0 ~ ".*pattern.*" {a=$1; if(!(a in count)) {keyInOrder[i++]=a}; count[a]++} \
 END{for(i=0; i<length(keyInOrder); i++) {a=keyInOrder[i]; print a, count[a]}}' test.csv
```

Use this awk script to check if a CSV contains the same number of columns on each line:
[check_column_count.sh](/scripts/check_column_count.sh)
```bash
$ ./check_column_count.sh sample.csv
   column count     lines count               %
              3              20         95.2381
              4               1          4.7619
Columns count is not uniform, but in large majority it is 3 columns.
1 Outlier Line(s):
M,Alphonse,1932,plop

To send all 1 outlier lines by mail:
echo "The number of columns in this file should be 3." |
 mail -s "Outlier lines in sample.csv" -a <(awk -F"," "NF != 3 {print \$0}" "sample.csv") seb@mail.com
```

### Head & Tail

```
head -5      # Print the first 5 lines
head -n 5    # Print the first 5 lines
head -n -5   # Print all but the last 5 lines, ie from start to END-5

tail -5      # Print the last 5 lines
tail -n -5   # Print the last 5 lines
tail +5      # Print from 5th line to the end
tail -n +5   # Print from 5th line to the end
```

## Search & Replace
Search files based on modification date
```bash
find ~/folder -newermt "Jan 20, 2018 00:00" -type f -path "/subfolder/\|/subdir/" -print > result_$(date +"%Y%m%d").txt
find ~/folder -newermt "Jan 20, 2018 00:00" ! -newermt "Jan 26, 2018 00:00" -type f -print 

find -type f -printf "%T@ %Tc %p\n" | sort -k 1nr | sed 's/^[^ ]* //' | head -n 100 |less
```


Find/Replace in files with sed or tr
```bash
sed -i "s/rechercher/remplacer/g" *
$ echo "chat" | tr a u
chut
$ echo "chat" | tr [a-z] [A-Z]
CHAT
$ echo -e "Text \t with    large     spaces." | tr -s [:blank:] " "
Text with large spaces.
$ echo -e "1\t2\t3\t4" | tr \\t \;
1;2;3;4
$ echo -e "1\t2\t3\t4" | tr '\t' '|'
1|2|3|4
```

Extract a substring between two patterns
(sed doesn't recognize the lazy `*?` quantifier)
```bash
$ s="This is the word I want to extract."
$ echo "$s" | sed 's/.*the \([^ ]*\) I.*/\1/g'
word
```

Delete lines containing a pattern:
```bash
for i in files*.csv;
do
  sed -i '/^.*pattern.*$/d' "$i"
done
```

Replace in vim
- in all lines:
> :**%**s/search/replace/g
- in the current line only (all occurences (g)):
> :s/search/replace/g
- with case insensitive and confirmation
> :%s/search/replace/g**ci**
- within visual selection: enable selection mode with Ctrl+V, select area and type ```:``` before entering search pattern
> :'<,'>s/search/replace/g
- highlight search matches:
> :set hlsearch


Find and delete broken symbolic links
```bash
find . -type l -xtype l -exec ls -l --color {} \;
find . -type l -xtype l -delete
```

Find compatible with filenames containing spaces and executes an action on each one
```bash
find . -print0 | while IFS= read -r -d '' file; do <dosomething> "$file"; done
```

Find empty files and symbolic links pointing to empty files
```bash
find -L . -size 0 -exec ls -l {} \;
```

Supprimer les csv qui ont déjà un csv.gz
```bash
for i in *.csv.gz; do if [ -f ${i%.gz} ]; then echo "rm ${i%.gz}"; fi; done
for i in *.csv.gz; do if [ -f ${i%.gz} ]; then echo "rm ${i%.gz}"; rm ${i%.gz}; fi; done
```

Search files modified after a given date and copy them while keeping subdirectories tree structure in the destination folder, 
can be used for quick incremental backup
```bash
find . -type f -newermt "Feb 14" -exec cp --parents {} destination/ \;

find . -type f -newermt "Feb 14" -exec bash -c 'targetDir="destination"; if [ ! -d "$targetDir/"$(dirname "{}") ]; then mkdir -p "$targetDir/"$(dirname "{}"); fi; cp -i {} "$targetDir/"$(dirname "{}")/$(basename "{}")' \;
```


## TAR files
Show the content of tar.gz file
```
tar -tvf file.tar
tar -ztvf file.tar.gz
tar -jtvf file.tar.bz2
```

Create a compressed tar
```
tar -zcvf ../tarball.tar.gz file1 file2
tar -Jcvf ../tarball.tar.xz --owner=:0 --group=:0 -C /ignore/path/ keep/path/
```
Extract the content of tar.gz file in a specific folder
```
tar -zxvf tarball.tar.gz -C <directory>
tar -zxvf tarball.tar.gz -C <directory> --strip-components=NUMBER # strip NUMBER leading components from file names
```

Gzip/Gunzip a file **k**eeping the original file
```
gzip -k file
gunzip -k file.gz
gunzip -kc file.gz > /destinationDir/file
```
Unzip a set of files in a directory:
```
unzip \*.jar -d destination
```

## grep options ##
```bash
-l, --files-with-matches
-L, --files-without-match

-H, --with-filename (default when multiple files)
-h, --no-filename
```


## Files comparison
Compare files between servers
```bash
comm -23 <(ls ~/folder/ | sort) <(ssh user@server "ls ~/folder/" | sort)
```

Compare files list between servers and copy missing files (older than 1 min) to the other server
```bash
comm -23 <(find ~/folder -type f -mmin +1 -printf "%f\n" | sort) <(ssh user@server "ls ~/folder/" | sort) |
 grep pattern | xargs -I % scp ~/folder/% user@server:~/folder/
```

Compare files in two folders based on MD5:
```bash
for i in $DIR1/*;
do
  i=$(basename $i)
  checksum1=$(md5sum "$DIR1/$i")
  checksum2=$(md5sum "$DIR2/$i")

  if [[ "${checksum1%% *}" == "${checksum2%% *}" ]]
  then
    echo "= $i";
  else
    echo "<> $i";
  fi
done | less
```

## Links
```
ln -s <targetfile> <creationdir/linkname>
```
Create symbolic link towards absolute path of physical file
```
ln -s $(realpath <targetfile>) <creationdir/linkname>  # since GNU coreutils 8.15
ln -s $(readlink -f <targetfile>) <creationdir/linkname>
```

## Process

```
$ ps faux  # Forest tree format, BSD syntax
$ ps -A u  # -A = -e = Select all processes
USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root         1  0.0  0.8  27136  6056 ?        Ss   Feb10   3:12 /sbin/init
$ ps -eF   # Standard Unix syntax: all processes, extra full-format listing
UID        PID  PPID  C    SZ   RSS PSR STIME TTY          TIME CMD
root         1     0  0  6784  6056   2 Feb10 ?        00:03:12 /sbin/init
$ ps a  # Lift the BSD-style "only yourself" restriction
$ ps x  # Lift the BSD-style "must have a tty" restriction
$ ps u  # Display the BSD-style user-oriented format
$ ps --no-headers  # without header, useful in script
```
Display only process of a specific command (with -C), sorted by %CPU, without header
Extract a pattern from command line with sed
```
$ ps h -o pid,comm,args -C nginx k -pcpu
  686 nginx           nginx: master process /usr/sbin/nginx -g daemon on; master_process on;
  687 nginx           nginx: worker process
  688 nginx           nginx: worker process
  689 nginx           nginx: worker process
  690 nginx           nginx: worker process

$ ps h -o pid,pcpu,pmem,rss,args -C nginx k -pcpu | sed 's/nginx: \([^ ]*\) process.*/\1/g'
  686  0.0  0.3  2260 master
  687  0.0  0.4  3220 worker
  688  0.0  0.4  3216 worker
  689  0.0  0.4  3220 worker
  690  0.0  0.4  3220 worker
```

To find which process is using a file, a directory or a socket:
```
$ fuser file
$ fuser -k file  #  Kill processes accessing the file
```


## Monitoring
Disk space left
```bash
$ df -Ph | grep " /$" | awk '{ sub(/%/, "", $5); if ($5.0 > 85) {alert="\033[1;31m"} {print alert $6, $4, (100-$5)"%\033[0m"}}'
/ 3.7G 30%
```

## Encoding
### Hexadecimal display
```bash
hexdump -C <file>
xxd -g1 <file>
```

### Charset conversion
```bash
$ env | grep LANG
LANG=fr_FR.UTF-8
$ locale
LANG=fr_FR.UTF-8
LC_CTYPE="fr_FR.UTF-8"
...
$ echo "été €" > charset.txt
$ hexdump -C charset.txt
00000000  c3 a9 74 c3 a9 20 e2 82  ac 0a                    |..t.. ....|
$ iconv -f UTF8 -t CP1252 charset.txt | hexdump -C
00000000  e9 74 e9 20 80 0a                                 |.t. ..|
$ iconv -f UTF8 -t ISO8859-1 charset.txt | hexdump -C
iconv: charset.txt:1:4: cannot convert
00000000  e9 74 e9 20                                       |.t. |
$ iconv -f UTF8 -t ISO8859-15 charset.txt | hexdump -C
00000000  e9 74 e9 20 a4 0a                                 |.t. ..|

# iconv -f <from-encoding> -t <to-encoding> <file>
```

## Network

### DNS
```
$ dig +noall +answer google.com
google.com.             46      IN      A       216.58.198.206
$ dig +short google.com
216.58.204.142
$ nslookup google.com
Server:         192.168.0.254
Address:        192.168.0.254#53

Non-authoritative answer:
Name:   google.com
Address: 216.58.198.206
Name:   google.com
Address: 2a00:1450:4007:80c::200e

$ host 216.58.198.206
206.198.58.216.in-addr.arpa domain name pointer par10s27-in-f14.1e100.net.
206.198.58.216.in-addr.arpa domain name pointer par10s27-in-f206.1e100.net.
$ dig -x 216.58.198.206
;; ANSWER SECTION:
206.198.58.216.in-addr.arpa. 79054 IN   PTR     par10s27-in-f206.1e100.net.
206.198.58.216.in-addr.arpa. 79054 IN   PTR     par10s27-in-f14.1e100.net.
```

### Netcat
```
$ printf "GET / HTTP/1.0\r\nHost: google.com\r\n\r\n" | nc 216.58.198.206 80
HTTP/1.0 301 Moved Permanently
Location: http://www.google.fr/
Content-Type: text/html; charset=UTF-8
Date: Fri, 13 Apr 2018 22:35:00 GMT
Expires: Sun, 13 May 2018 22:35:00 GMT
Cache-Control: public, max-age=2592000
Server: gws
Content-Length: 218
X-XSS-Protection: 1; mode=block
X-Frame-Options: SAMEORIGIN

<HTML><HEAD><meta http-equiv="content-type" content="text/html;charset=utf-8">
<TITLE>301 Moved</TITLE></HEAD><BODY>
<H1>301 Moved</H1>
The document has moved
<A HREF="http://www.google.fr/">here</A>.
</BODY></HTML>
$ printf "GET / HTTP/1.0\r\nHost: www.google.fr\r\n\r\n" | nc 216.58.198.206 80
```

Connect via HTTP proxy with authentication with username “user”
```
$ nc -x10.2.3.4:8080 -Xconnect -Puser internet.example.com 80
```

Scan port range, timeout 1s, without DNS query
```
$ nc -zvn -w1 host.example.com 20-25,80,443
```

Listening on localhost on port 8080, keep listening
```
$ nc -lk 8080
$ while true; do nc -l 8080 < file.txt; done
$ while true; do echo "$(date)" | nc -l 8080; done
```
Transfer the content of a directory to another host through tar.gz
```
$ nc -l 3000 | tar xzvf -
$ tar czvf - dir2transfer | nc hostReceiver 3000
```

### Nmap

```
nmap 192.168.0.0/25 -sP      # Ping scan (sP = sn) -sP option is now obsolete and renamed as -sn
nmap 192.168.0.* -sn         # No port scan after host discovery, consists of an ICMP echo request, TCP SYN to port 443, TCP ACK to port 80, and an ICMP timestamp request by default. When executed by an unprivileged user, only SYN packets are sent (using a connect call) to ports 80 and 443 on the target.
nmap 192.168.0.0/25 -p22,80  # Scan specific ports
nmap 192.168.0.0/25 -Pn      # Skip host discovery
```
The flags -sP and -P0 are now known as -sn and -Pn respectively.

### ARP (Address Resolution Protocol)
Print ARP table content
```
arp -n
ip neighbour
ip n
```