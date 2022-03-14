export async function getMenuItems() {
  const url = process.env.VUE_APP_MENU_SERVICE_URL;
  const response = await fetch(url, {
    mode: 'cors',
    method: 'GET',
  })
  const menuItems = await response.json();
  return menuItems.map(m => ({
    id: m.id,
    title: m.tagLine,
    subtitle: m.itemName,
    image: m.itemImageURL,
    price: m.itemPrice,
    spiceLevel: m.spiceLevel
  }));
}
  
export async function getInventoryCounts() {
  console.time('getInventoryCounts')
  const url = process.env.VUE_APP_INVENTORY_SERVICE_URL;
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

export async function placeOrder(name, address, city, state, zip, orderItems) {
  const url = process.env.VUE_APP_ORDER_SERVICE_URL;
  //const url = 'https://order-service-luu7kai33a-uc.a.run.app/place-order';
  const payload = {name, address, city, state, zip, orderItems};
  const response = await fetch(url, {
    method: 'POST',
    mode: 'cors',
    headers: {'Content-Type': 'application/json'},
    body: JSON.stringify(payload)
  });
  const respObj = await response.json();
  return respObj.orderNumber;
}

export async function createMenuItem(tagLine, itemName, itemPrice, spiceLevel) {
  const url = process.env.VUE_APP_MENU_SERVICE_URL;
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