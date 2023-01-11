# Copyright 2023 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

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
