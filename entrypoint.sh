#!/usr/bin/env bash

set -e
echo "Running Load Test"

# $1 is the path of the Load Test
# $2 is the output path for reports

artillery run --output report.json $1

OUTPUT_PDF=$(date +"%y-%m-%d-%H-%M-%S").html
DIR=$(dirname $OUTPUT_PDF)

PUSH_PATH=$2
if [[ ! -z $PUSH_PATH ]]; then
  if [[ ${PUSH_PATH:0:1} == "/" ]]; then
    PUSH_PATH=${PUSH_PATH:1}
  fi
  DIR=$PUSH_PATH
  OUTPUT_PATH="$DIR/$OUTPUT_PDF"
fi

artillery report --output $OUTPUT_PDF report.json

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
    if [ "$NAME" = "$OUTPUT_PDF" ]; then
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
            https://api.github.com/repos/${GITHUB_REPOSITORY}/contents/${OUTPUT_PATH})

if [ $((STATUSCODE/100)) -ne 2 ]; then
  echo "Github's API returned $STATUSCODE"
  exit 22;
fi