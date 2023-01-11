/**
 * Copyright 2023 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

export async function getAllMenuItems() {
  console.time('getMenuItems');
  const url = process.env.VUE_APP_MENU_SERVICE_URL+"/menu";
  const response = await fetch(url, {
    mode: 'cors',
    method: 'GET',
  })
  console.timeEnd('getMenuItems');
  if (!response.ok) {
    const message = `An error has occured: ${response.status}`;
    console.log(message);
    return JSON.parse("[]");
  }
  return await response.json();
}

export async function getInventoryCounts() {
  console.time('getInventoryCounts')
  const url = process.env.VUE_APP_INVENTORY_SERVICE_URL+"/getAvailableInventory";
  const response = await fetch(url, {
    mode: 'cors',
    method: 'GET',
  })
  if (!response.ok) {
    const message = `An error has occured: ${response.status}`;
    console.log(message);
    return JSON.parse("[]");
  }
  const inventoryCounts = await response.json();
  console.timeEnd('getInventoryCounts')
  return inventoryCounts.map(ic => ({
    id: ic.ItemID,
    inventory: ic.Inventory
  }));
}

export async function createMenuItem(tagLine, itemName, itemPrice, spiceLevel) {
  const url = process.env.VUE_APP_MENU_SERVICE_URL + '/menu';
  const payload = {tagLine, itemName, itemPrice, spiceLevel};
  const response = await fetch(url, {
    method: 'POST',
    mode: 'cors',
    headers: {'Content-Type': 'application/json'},
    body: JSON.stringify(payload)
  });
  const respObj = await response.json();
  return respObj;
}

export async function updateInventoryCount(menuItemId, inventoryCountChange) {
  const url = process.env.VUE_APP_INVENTORY_SERVICE_URL + '/updateInventoryItem';
  const payload = [{itemID: menuItemId, inventoryChange: inventoryCountChange}];
  console.log('Hitting ', url);
  console.log('Payload ', payload);
  const response = await fetch(url, {
    method: 'POST',
    mode: 'cors',
    headers: {'Content-Type': 'application/json'},
    body: JSON.stringify(payload)
  });
  console.log(response);
}

export async function cancelOrder(orderNumber) {
  const url = process.env.VUE_APP_ORDER_SERVICE_URL + '/order/' + orderNumber;
  console.log('Hitting ', url);
  const response = await fetch(url, {
    method: 'DELETE',
    mode: 'cors'
  });
  const respObj = await response.json();
  if (respObj.error) throw error;
}

export async function updateOrderStatus(orderNumber, newStatus) {
  const url = process.env.VUE_APP_ORDER_SERVICE_URL + '/order/' + orderNumber;
  const payload = {'status': newStatus};
  console.log('Hitting ', url);
  console.log('Payload ', payload);
  const response = await fetch(url, {
    method: 'PATCH',
    mode: 'cors',
    headers: {'Content-Type': 'application/json'},
    body: JSON.stringify(payload)
  });
  const respObj = await response.json();
  if (respObj.error) throw error;
}
