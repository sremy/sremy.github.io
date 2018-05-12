#!/bin/bash
# Script to check that a CSV file has a constant number of column in each lines
# Fields separation is handled by awk with -F argument
# If more than PERCENTAGE_TRESHOLD% (but less than 100%) of lines have the same number of columns, then this columns count is considered as the good one.
# All lines with a different columns count can be sent by mail to be analyzed.
# CSV and CSV.GZ files are supported

PERCENTAGE_TRESHOLD=90;
FIELD_SEPARATOR="\t"

awk -F$FIELD_SEPARATOR -v percentage_treshold=$PERCENTAGE_TRESHOLD -v input_file="$1" '
BEGIN{
  printf "%15s %15s %15s\n", "column count", "lines count", "%"
}
{
  count[NF]++; total++
}
END{
  for (a in count) {
    percentage = count[a]/total*100;
    if(percentage < 100 && percentage > percentage_treshold){
      majority = a;
      color = "\033[1;32m";
    }
    else if(percentage == 100) {
      uniform = a;
      color = "\033[1;32m";
    }
    else if(percentage < percentage_treshold){
      color = "\033[1;31m";
      nb_outlier_lines += count[a]
    }
    printf "%s%15s %15s %15s\033[0m\n", color, a, count[a], percentage;
  }
  if(uniform != "") {
    printf "Columns count is \033[1muniform\033[0m: \033[1;32m%s\033[0m columns.\n", uniform;
  }
  if (majority != "") {
    for(n=0;n<=255;n++) {ord[sprintf("%c",n)]=n; }
    field_sep = sprintf ("\\x%x", ord[FS])
    printf "Columns count is \033[1mnot uniform\033[0m, but in large majority it is \033[1;32m%s\033[0m columns.\n", majority;
    print ("\033[4m" nb_outlier_lines " Outlier Line(s):\033[0m")
    system("zcat -f \"" input_file "\"| awk -F\""FS"\" \" NF != " majority " {print \$0}\" | head -10")
    if(match(input_file, ".*\.(gz|GZ)$")) {
      uncompressed_file = "<(zcat \""input_file"\")";
    }
    else {
      uncompressed_file = "\""input_file"\"";
    }
    print("\nTo send all " nb_outlier_lines " outliner lines by mail:");
    print("echo \"The number of columns in this file should be " majority ".\" | mail seb@mail.com -s \"Outlier lines in "input_file"\" -a <(awk -F\""field_sep"\" \"NF != " majority " {print \$0}\" " uncompressed_file ")")
    #print("echo \"The number of columns in this file should be " majority ".\" | mail seb@mail.com -s \"Outlier lines in "input_file"\" -a <( zcat -f \"" input_file "\" | awk -F\""field_sep"\" \"NF != " majority " {print \$0}\" )")
  }
}
' <(zcat -f "$1")
