const express = require('express');
const cors = require('cors');
const app = express();
app.use(cors());
app.use(express.json());
const port = process.env.PORT || 8080;
app.listen(port, () => {
  console.log(`API listening on port ${port}`);
});
const {Firestore} = require('@google-cloud/firestore');
const firestore = new Firestore();

const inventoryServer = axios.create({
  baseURL: process.env.INVENTORY_SERVICE_URL,
  headers :{ 
      get: {
          "Content-Type": 'application/json'
      }
  }
})

app.post('/place-order', async (req, res) => {
  try {
    const orderNumber = getNewOrderNumber();
    const orderDoc = firestore.doc(`orders/${orderNumber}`);
    await orderDoc.set({
      orderNumber: orderNumber,
      name: req.body.name,
      address: req.body.address,
      city: req.body.city,
      state: req.body.state,
      zip: req.body.zip,
      orderItems: req.body.orderItems,
      status: 'New',
      statusUpdatedAt: new Date(),
      placedAt: new Date()
    })

    inventoryServer.POST("/updateInventoryItem", 
      req.body.orderItems.map(x => ({
        itemID: x.id,
        inventoryChange: x.quantity
      }))
    );

    res.json({orderNumber: orderNumber});
  }
  catch(ex) {
    res.status(500).json({error: ex.toString()});
  }
})

function getNewOrderNumber() {
  return Math.round(Math.random() * 100000);
}
