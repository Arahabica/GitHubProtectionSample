#!/bin/bash

DIR=$(cd $(dirname $0); pwd)

hub api user
echo -e "\nLogged in.\n\n"
TOKEN=`cat ~/.config/hub | grep oauth_token | sed "s/ //g" | sed "s/oauth_token://g"`

REPO=`git config --get remote.origin.url | sed s/git@github.com://g | sed s/.git$//g`

RES=`cat "${DIR}/protections.json" | jq -r 'to_entries[] | "\(.key)__DELIMITER__\(.value)"'`
for line in ${RES}; do
   BRANCH=`echo ${line} | sed -e "s/__DELIMITER__.*$//g"`
   BODY=`echo ${line} | sed -e "s/^.*__DELIMITER__//g"`
   curl \
     -X PUT \
     -H "Accept: application/vnd.github.luke-cage-preview+json" \
     -H "Authorization: token ${TOKEN}" \
     "https://api.github.com/repos/${REPO}/branches/${BRANCH}/protection" \
     -d ${BODY}
done
