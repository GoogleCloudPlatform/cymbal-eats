echo "DURATION=$DURATION"
echo "MENU_SERVICE_URL=$MENU_SERVICE_URL"
# Failed items older than DURATION in minutes
for id in $(http GET $MENU_SERVICE_URL/menu/failed | jq '[.[] | select(.updateDateTime < ((now - 60 * (env.DURATION | tonumber) )| strftime("%Y-%m-%dT%H:%M:%S.%f")))]'| jq '.[].id'); do
   echo "Deleting Menu Item : $MENU_SERVICE_URL/menu/$id"
   http GET $MENU_SERVICE_URL/menu/$id
   http DELETE $MENU_SERVICE_URL/menu/$id
done

# Processing items older than DURATION in minutes
for id in $(http GET $MENU_SERVICE_URL/menu/processing | jq '[.[] | select(.updateDateTime < ((now - 60 * (env.DURATION | tonumber))| strftime("%Y-%m-%dT%H:%M:%S.%f")))]'| jq '.[].id'); do
 echo "Deleting Menu Item : $MENU_SERVICE_URL/menu/$id"
 http GET $MENU_SERVICE_URL/menu/$id
 http DELETE $MENU_SERVICE_URL/menu/$id
done
