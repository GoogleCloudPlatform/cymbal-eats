// Copyright 2020 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

const express = require('express');
const fileUpload = require('express-fileupload');
const {Storage} = require('@google-cloud/storage');
const storage = new Storage();
const path = require('path');

const app = express();
app.use(fileUpload({
    limits: { fileSize: 10 * 1024 * 1024 },
    useTempFiles : true,
    tempFileDir : '/tmp/'
}))

const PORT = process.env.PORT || 8080;
app.listen(PORT, () => {
  console.log(`Started picture-upload-service on port ${PORT}`);
});

process.env.UPLOAD_BUCKET = 'gs://menu-item-uploads';

app.post('/', async (req, res) => {
  if (!req.files || Object.keys(req.files).length === 0) {
    console.log("No file uploaded");
    return res.status(400).send('No file was uploaded.');
  }
  console.log(`Receiving file ${JSON.stringify(req.files.picture)}`);
  console.log(`MenuItemId: `, req.body.menuItemId);

  const pictureFileExtension = getFileExtension(req.files.picture.name);
  const newPictureName = req.body.menuItemId + '.' + pictureFileExtension;
  const newPicture = path.resolve('/tmp', newPictureName);
  await req.files.picture.mv(newPicture);
  console.log(`File "${newPictureName}" moved to /tmp`);

  const pictureBucket = storage.bucket(process.env.UPLOAD_BUCKET);
  await pictureBucket.upload(newPicture, { resumable: false });
  console.log(`Uploaded "${newPictureName}" to Cloud Storage bucket "${process.env.UPLOAD_BUCKET}"`);

  res.json({status: 'Success'});
});

function getFileExtension(fileName) {
  return fileName.split('.').pop();
}
