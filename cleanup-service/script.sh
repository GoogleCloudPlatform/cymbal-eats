echo "FAILED_ITEM_AGE=$FAILED_ITEM_AGE"
echo "MENU_SERVICE_URL=$MENU_SERVICE_URL"
# Failed items older than FAILED_ITEM_AGE in minutes
for id in $(http GET $MENU_SERVICE_URL/menu/failed | jq '[.[] | select(.updateDateTime < ((now - 60 * (env.FAILED_ITEM_AGE | tonumber) )| strftime("%Y-%m-%dT%H:%M:%S.%f")))]'| jq '.[].id'); do
   echo "Deleting Menu Item : $MENU_SERVICE_URL/menu/$id"
   http GET $MENU_SERVICE_URL/menu/$id
   http DELETE $MENU_SERVICE_URL/menu/$id
done

# Processing items older than FAILED_ITEM_AGE in minutes
for id in $(http GET $MENU_SERVICE_URL/menu/processing | jq '[.[] | select(.updateDateTime < ((now - 60 * (env.FAILED_ITEM_AGE | tonumber))| strftime("%Y-%m-%dT%H:%M:%S.%f")))]'| jq '.[].id'); do
 echo "Deleting Menu Item : $MENU_SERVICE_URL/menu/$id"
 http GET $MENU_SERVICE_URL/menu/$id
 http DELETE $MENU_SERVICE_URL/menu/$id
done
