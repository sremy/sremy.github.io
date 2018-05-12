## Bash useful commands

Sort files recursively
- Latest files at the top
```bash
function findLatest () {
    find -L $1 ! -type d -printf "%T@ %Tc %11s %p\n" | sort -k 1nr | sed 's/^[^ ]* //' less
}
```
- Biggest files at the top
```bash
find -L . ! -type d -printf "%Tc %11s %p\n" | sort -r -n -k2
find -L . ! -type d -ls | sort -r -n -k7
```

Builtin functions
```bash
for n in {1..100}
do
    echo $n $((n*n)) $[n*(n+1)/2]
done
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

## Search & Replace
Search files based on modification date
```bash
find ~/folder -newermt "Jan 20, 2018 00:00" -type f -print | grep "/subfolder/\|/subdir/" > result_$(date +"%Y%m%d").txt
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

Extract the content of tar.gz file in a specific folder
```
tar -zxvf tarball.tar.gz -C <directory>
```
Create a tar.gz 
```
tar -zcvf ../tarball.tar.gz file1 file2
```
Gzip/Gunzip a file keeping the original file
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
comm -23 <(find ~/folder -type f -mmin +1 -printf "%f\n" | sort) <(ssh user@server "ls ~/folder/" | sort) | grep pattern | xargs -I % scp ~/folder/% user@server:~/folder/
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
ln -s $(realpath <targetfile>) <creationdir/linkname>
```

## Process

```
ps faux
ps -ef
ps -A u
```
Display only process of a specific command, sorted by %CPU, without header
Extract a pattern from command line
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
$ host 216.58.198.206
206.198.58.216.in-addr.arpa domain name pointer par10s27-in-f14.1e100.net.
206.198.58.216.in-addr.arpa domain name pointer par10s27-in-f206.1e100.net.
$ dig -x 216.58.198.206
;; ANSWER SECTION:
206.198.58.216.in-addr.arpa. 79054 IN   PTR     par10s27-in-f206.1e100.net.
206.198.58.216.in-addr.arpa. 79054 IN   PTR     par10s27-in-f14.1e100.net.
$ nslookup google.com
Server:         192.168.0.254
Address:        192.168.0.254#53

Non-authoritative answer:
Name:   google.com
Address: 216.58.198.206
Name:   google.com
Address: 2a00:1450:4007:80c::200e
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
```