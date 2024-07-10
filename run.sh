#!/bin/bash
echo "Start logs"

if [! -e logs.txt ]; then
  touch logs.txt
fi
if [! -e values.txt ]; then
  touch values.txt
fi

URL="..."
INTERVAL=5
REPORTINTERVAL=0

INCREMENT=$(tail -n 2 values.txt | head -n 1)
NBERROR=$(tail -n 1 values.txt)

if [ -z "$NBERROR" ]; then
    NBERROR=0
fi
if [ -z "$INCREMENT" ]; then
    INCREMENT=0
fi

rm values.txt && touch values.txt

runLogs()
{
while true; do
  RESPONSE=$(curl -o /dev/null -s -w "%{http_code}\n" "$URL")

  if [ "$RESPONSE" -eq 400 ]; then
    cat >> logs.txt << catStop
ERROR $(date +%Y-%m-%d\ %H:%M:%S) Erreur: 400 Bad Request
catStop

    ((NBERROR++))

  else
    cat >> logs.txt << catStop
PASS $(date +%Y-%m-%d\ %H:%M:%S) Code de réponse: $RESPONSE
catStop

  fi

  if [ $REPORTINTERVAL -eq 12 ]; then
    ((REPORTINTERVAL = 0))

    cat >> logs.txt << catStop
REPORT Pourcentage erreur: $(( (NBERROR/INCREMENT) * 100))%
catStop

  fi

  ((INCREMENT++))

  sleep $INTERVAL

  cat >> values.txt << catStop
$INCREMENT
$NBERROR
catStop

  ((REPORTINTERVAL++))  

done
}


runLogs &

cat <<< $! >> values.txt
