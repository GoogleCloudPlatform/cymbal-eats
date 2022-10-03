const express = require('express');
const app = express();
app.use(express.json());
const port = process.env.PORT || 8080;
app.listen(port, () => {
  console.log(`API listening on port ${port}`);
});
const {Firestore} = require('@google-cloud/firestore');
const db = new Firestore();

app.get('/', async (req, res) => {
  res.send("Partner registration service: RUNNING")
})

app.get('/partners', async (req, res) => {
  try {
    const partnerCollection = await db.collection('partners').get();
    const partners = partnerCollection.docs.map(d => d.data());
    res.json({status: 'success', data: partners});
  }
  catch(ex) {
    console.error(ex);
    res.status(500).json({error: ex.toString()});
  }
})

app.post('/partner', async (req, res) => {
  try {
    const partnerRecord = await savePartnerRecord(req.body);
    res.json({status: 'success', data: partnerRecord});
  }
  catch(ex) {
    console.error(ex);
    res.status(500).json({error: ex.toString()});
  }
})

async function getPartnerRecord(partnerId) {
  const partnerDoc = await db.doc(`partners/${partnerId}`).get();
  return partnerDoc.data();
}

async function savePartnerRecord(requestBody) {
  const partnerId = getNewPartnerId();
  const partnerDocRef = db.doc(`partners/${partnerId}`);
  await partnerDocRef.set({
    partnerId: partnerId,
    createdAt: new Date(),
    ...requestBody
  });
  return await getPartnerRecord(partnerId);
}

function getNewPartnerId() {
  return Math.round(10000 + Math.random() * 90000);
}
