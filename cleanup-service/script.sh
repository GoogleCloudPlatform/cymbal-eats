#MENU_SERVICE_URL=https://menu-service-swlpuretuq-ue.a.run.app
echo DURATION $DURATION
# Failed items older than DURATION in minutes
for id in $(http GET $MENU_SERVICE_URL/menu/failed | jq '[.[] | select(.updateDateTime < ((now - 60 * (env.DURATION | tonumber) )| strftime("%Y-%m-%dT%H:%M:%S.%f")))]'| jq '.[].id'); do
   echo Deleting Menu Item :
   http GET $MENU_SERVICE_URL/menu/$id
   http DELETE $MENU_SERVICE_URL/menu/$id
done

# Processing items older than DURATION in minutes
for id in $(http GET $MENU_SERVICE_URL/menu/processing | jq '[.[] | select(.updateDateTime < ((now - 60 * (env.DURATION | tonumber))| strftime("%Y-%m-%dT%H:%M:%S.%f")))]'| jq '.[].id'); do
 echo Deleting Menu Item :
 http GET $MENU_SERVICE_URL/menu/$id
 http DELETE $MENU_SERVICE_URL/menu/$id
done
