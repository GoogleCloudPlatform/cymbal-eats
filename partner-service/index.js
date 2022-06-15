const express = require('express');
const app = express();
app.use(express.json());
const port = process.env.PORT || 8080;
app.listen(port, () => {
  console.log(`API listening on port ${port}`);
});
const {Firestore} = require('@google-cloud/firestore');
const db = new Firestore();

app.get('/partner-order/:partnerId', async (req, res) => {
  try {
    const partnerId = req.params.partnerId;
    const orderColl = await db.collection(`orders`)
                              .where('partnerId', '==', partnerId).get();
    const orders = orderColl.docs.map(d => d.data());
    res.json({status: 'success', data: orders});
  }
  catch(ex) {
    console.error(ex);
    res.status(500).json({error: ex.toString()});
  }
})

app.post('/partner-order', async (req, res) => {
  try {
    const orderNumber = await createOrderRecord(req.body);
    res.json({orderNumber: orderNumber});
  }
  catch(ex) {
    console.error(ex);
    res.status(500).json({error: ex.toString()});
  }
})

async function createOrderRecord(requestBody) {
  const orderNumber = getNewOrderNumber();
  const orderDoc = db.doc(`orders/${orderNumber}`);
  await orderDoc.set({
    orderNumber: orderNumber,
    partnerId: requestBody.partnerId,
    name: requestBody.name,
    email : requestBody.email,
    address: requestBody.address,
    city: requestBody.city,
    state: requestBody.state,
    zip: requestBody.zip,
    orderItems: requestBody.orderItems,
    status: 'New',
    statusUpdatedAt: new Date(),
    placedAt: new Date()
  });
  return orderNumber;
}

function getNewOrderNumber() {
  return Math.round(10000 + Math.random() * 90000);
}
