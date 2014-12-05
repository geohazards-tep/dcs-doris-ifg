#!/bin/bash 

master=$1
slave=$2

function extract() {

  local archive=$1

  # get the archive contents
  tar tfz $archive > tar.list

  # get the name of the leader file
  baselea=`cat tar.list | grep "\.xml$" | sed 's#.*/\(.*\)#\1#g' | grep "^T.*\.xml"`
  lea=`cat tar.list | grep $baselea`
  depth=`echo $lea | grep -o "/" | wc -l`

  #extract the header file
  tar -zxvf $archive $lea --strip-components $depth

  # get the dataset date
  folder=`cat $baselea | xsltproc tsx.xsl - | date '+%Y%m%d'`

  # create the data folder
  mkdir -p data/$folder

  # put the leader file in it
  mv $baselea data/$folder

  # extract the data file
  basecos=`cat tar.list | grep "\.cos$" | sed 's#.*/\(.*\)#\1#g'`
  cos=`cat tar.list | grep $basecos`
  depth=`echo $cos | grep -o "/" | wc -l`

  tar -C data/$folder -zxvf $archive $cos --strip-components $depth

  rm -f tar.list
}

extract $master

extract $slave

# check if cos have the same name, DORIS doesn't like it
[ "`find data -name "*.cos" | xargs -I {} basename {} | sort -u | wc -l`" == "1" ] && {
  # rename the slave
  slave="`find date -name "*.cos" | tail -n 1`"
  newslave="`echo "$slave" | sed "s#\(.*_\)\([0-9].*\)\(\.cos\)#\1$( printf %03d $( echo "$( basename "$slave" | sed 's#.*_\(.*\)\.cos#\1#g' ) + 1" | bc ) )\3#g"`"
  mv $slave $newslave
}

