#!/usr/bin/env bash

set -e
echo "Running Load Test"

# $1 is the path of the Load Test
# $2 is the output path for reports

artillery run --output report.json $1
OUTPUT_PDF=$2/$(date +"%y-%m-%d-%H-%M-%S").html
artillery report --output $OUTPUT_PDF report.json

FILE_NAME=$(basename $OUTPUT_PDF)
DIR=$(dirname $OUTPUT_PDF)

STATUSCODE=$(curl --silent --output resp.json --write-out "%{http_code}" -X GET -H "Authorization: token $GITHUB_TOKEN" https://api.github.com/repos/${GITHUB_REPOSITORY}/contents/$DIR)

if [ $((STATUSCODE/100)) -ne 2 ]; then
  echo "Github's API returned $STATUSCODE"
  cat resp.json
  exit 22;
fi

SHA=""
for i in $(jq -c '.[]' resp.json);
do
    NAME=$(echo $i | jq -r .name)
    if [ "$NAME" = "$FILE_NAME" ]; then
        SHA=$(echo $i | jq -r .sha)
        break
    fi    
done

echo '{
  "message": "'"update $OUTPUT_PDF"'",
  "committer": {
    "name": "Automated Artillery Action",
    "email": "automated-artillery-action@github.com"
  },
  "content": "'"$(base64 -w 0 $OUTPUT_PDF)"'",
  "sha": "'$SHA'"
}' > payload.json

STATUSCODE=$(curl --silent --output /dev/stderr --write-out "%{http_code}" \
            -i -X PUT -H "Authorization: token $GITHUB_TOKEN" -d @payload.json \
            https://api.github.com/repos/${GITHUB_REPOSITORY}/contents/${OUTPUT_PDF})

if [ $((STATUSCODE/100)) -ne 2 ]; then
  echo "Github's API returned $STATUSCODE"
  exit 22;
fi