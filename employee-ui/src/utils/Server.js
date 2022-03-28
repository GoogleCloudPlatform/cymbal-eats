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
  console.time('getInventoryCounts')
  const url = process.env.VUE_APP_INVENTORY_SERVICE_URL+"/getAvailableInventory";
  //const url = 'https://spanner-inventory-service-luu7kai33a-uc.a.run.app/getAvailableInventory';
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
  const url = process.env.VUE_APP_ORDER_SERVICE_URL + '/' + orderNumber;
  console.log('Hitting ', url);
  const response = await fetch(url, {
    method: 'DELETE',
    mode: 'cors'
  });
  const respObj = await response.json();
  if (respObj.error) throw error;
}

export async function updateOrderStatus(orderNumber, newStatus) {
  const url = process.env.VUE_APP_ORDER_SERVICE_URL + '/' + orderNumber;
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
