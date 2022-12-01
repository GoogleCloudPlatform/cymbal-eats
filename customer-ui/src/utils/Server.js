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
