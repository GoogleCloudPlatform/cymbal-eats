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

export async function getMenuItems() {
  console.time('getMenuItems');
  const url = process.env.VUE_APP_MENU_SERVICE_URL+"/menu/ready";
  const response = await fetch(url, {
    mode: 'cors',
    method: 'GET',
  })
  console.timeEnd('getMenuItems');
  return await response.json();
}

export async function getInventoryCounts() {
  console.time('getInventoryCounts');
  const url = process.env.VUE_APP_INVENTORY_SERVICE_URL+"/getAvailableInventory";
  const response = await fetch(url, {
    mode: 'cors',
    method: 'GET',
  })
  const inventoryCounts = await response.json();
  console.timeEnd('getInventoryCounts')
  return inventoryCounts.map(ic => ({
    id: ic.ItemID,
    inventory: ic.Inventory
  }));
}

export async function placeOrder(idToken, name, email, address, city, state, zip, orderItems) {
  const url = process.env.VUE_APP_ORDER_SERVICE_URL + "/order";
  const payload = {name, email, address, city, state, zip, orderItems};
  const response = await fetch(url, {
    method: 'POST',
    mode: 'cors',
    headers: {'Content-Type': 'application/json', 'Authorization': idToken},
    body: JSON.stringify(payload)
  });
  const respObj = await response.json();
  if (respObj.error) throw respObj.error;
  return respObj.orderNumber;
}

export async function getOrders(idToken) {
  console.time('getOrders');
  const url = process.env.VUE_APP_ORDER_SERVICE_URL+"/orders/customer";
  const response = await fetch(url, {
    method: 'GET',
    mode: 'cors',
    headers: {'Content-Type': 'application/json', 'Authorization': idToken},
  })
  const respObj = await response.json();
  console.timeEnd('getOrders')
  return respObj.data;
}
