#!/bin/bash

# Watch a directory for mtime changes and output a feed of them to .www/dir2feed/
# Suggested use: `ssh login.ccs.neu.edu ~/bin/CCIS-utils/dir2feed.sh cs4300 /course/cs4300/.www` in your feed reader.

set -o nounset
set -o errexit
cd "`dirname "$0"`"

NAME="$1"
DIR="$2"

function printUsage() {
  echo "Usage: checkup.sh name dir" >&2
}

if [ ! -d "$DIR" ] ; then
  echo "Directory to watch does not exist." >&2
  printUsage
  exit 2
fi

if [ \( ! -n "$NAME" \) -o \( "$NAME" != "`echo "$NAME" | sed 's/[^a-z0-9]//gi'`" \) ] ; then
  echo "Name must be nonempty alphanumeric string."
  printUsage
  exit 3
fi

function readTimes() {
  find -P "$DIR" -print0 | xargs -0 stat --format='%y -- %n' | sed "s|$DIR||" | sed 's/\.000000000//'
}

DDIR="`echo ~`/.www/dir2feed"

if [ ! -d "$DDIR" ] ; then
  mkdir "$DDIR"
fi

FCUR="$DDIR/$NAME-current.log"
FPREV="$DDIR/$NAME-previous.log"
FDIFF="$DDIR/$NAME-difference.log"
FXML="$DDIR/$NAME-items.part.xml"
FRSS="$DDIR/$NAME.rss"

touch "$FCUR" "$FPREV" "$FXML"
mv "$FCUR" "$FPREV"
readTimes > "$FCUR"
DIFFS="`diff "$FPREV" "$FCUR" | grep -e '^[<>]' \
        | sed 's|^<|---|' | sed 's|^>|+++|' | tee "$FDIFF"`"
WHEN="`date -R`"

function printFeed() {
  echo '<?xml version="1.0" encoding="UTF-8" ?>'
  echo '<rss version="2.0">'
  echo '<channel>'
  echo "<title>$NAME watcher</title>"
  echo "<description>Changes to files in $DIR</description>"
  echo '<link>about:blank</link>'
  echo "<lastBuildDate>$WHEN</lastBuildDate>"
  echo "<pubDate>$WHEN</pubDate>"
  
  cat "$FXML"
  
  echo '</channel>'
  echo '</rss>'
}

if [ -z "$DIFFS" ] ; then
  printFeed
  exit 0
fi

function printItem() {
  COUNT="`echo "$DIFFS" | wc -l`"
  MD5="`echo "$DIFFS" | md5sum | sed 's/.*\([a-z0-9]\{32\}\).*/\1/'`"
  echo '<item>'
  echo '<title>'"$COUNT"' changes ('"$WHEN"')</title>'
  echo '<description><![CDATA[Changes: <pre>'"$DIFFS"'</pre>]]></description>'
  echo '<link>about:blank</link>'
  echo '<guid isPermaLink="false">md5:'"$MD5"'</guid>'
  echo '<pubDate>'"$WHEN"'</pubDate>'
  echo '</item>'
}

if [ -n "`cat "$FPREV"`" ] ; then
  printItem >> "$FXML"
else
  touch "$FXML"
fi

printFeed | tee "$FRSS"

