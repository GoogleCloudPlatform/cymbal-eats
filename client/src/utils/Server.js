export async function getMenuItems() {
  const url = 'https://menu-service-luu7kai33a-uc.a.run.app/menu';
  // const url = 'https://spanner-inventory-service-luu7kai33a-uc.a.run.app/getAvailableInventory';
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
  
export async function placeOrder(name, address, city, state, zip, orderItems) {
  // const url = 'http://localhost:8080/place-order';
  const url = 'https://order-service-luu7kai33a-uc.a.run.app/place-order';
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
