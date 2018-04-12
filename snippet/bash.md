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



Find/Replace in files with sed
```bash
sed -i "s/rechercher/remplacer/g" *
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
find . -type l -xtype l -exec ls -l --color {}\;
find . -type l -xtype l -delete
```

Find compatible with filenames containing spaces and executes an action on each one
```bash
find . -print0 | while IFS= read -r -d '' file; do <dosomething> "$file"; done
```

Find symbolic links pointing to empty files
```bash
find -L . -size 0 -exec ls -l {} \;
```

Supprimer les csv qui ont déjà un csv.gz
```bash
for i in *.csv.gz; do if [ -f ${i%.gz} ]; then echo "rm ${i%.gz}"; fi; done
for i in *.csv.gz; do if [ -f ${i%.gz} ]; then echo "rm ${i%.gz}"; rm ${i%.gz}; fi; done
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
