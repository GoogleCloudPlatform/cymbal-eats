// Copyright 2021 Google LLC
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

const imageMagick = require('imagemagick');
const Promise = require("bluebird");
const path = require('path');
const {Storage} = require('@google-cloud/storage');
import axios from 'axios';


exports.process_thumbnails = async (file, context) => 
{
    try {

        console.log(`Received thumbnail request for file ${file.name} from bucket ${file.bucket}`);

        const storage = new Storage();
        const bucket = storage.bucket(file.bucket);
        const thumbBucket = storage.bucket(process.env.BUCKET_THUMBNAILS);

        const originalFile = path.resolve('/tmp/original', file.name);
        const itemID = parseInt(path.parse(file.name).name);

        if (isNaN(itemID)){
            res.status(500).send("Incorrect File Name");
            return;
        }

        await bucket.file(file.name).download({
            destination: originalFile
        });
        console.log(`Downloaded picture into ${originalFile}`);

        const resizeCrop = Promise.promisify(imageMagick.crop);
        await resizeCrop({
                srcPath: originalFile,
                dstPath: thumbFile,
                width: 400,
                height: 400
        });
        console.log(`Created local thumbnail in ${thumbFile}`);

        await thumbBucket.upload(thumbFile);
        console.log(`Uploaded thumbnail to Cloud Storage bucket ${process.env.BUCKET_THUMBNAILS}`);
        // Send update call to menu service
        const request = axios.create({
            headers :{ 
                post: {
                    "Content-Type": 'application/json'
                }
            }
        }).request({
            url: process.env.MENU_SERVICE_URL,
            method: 'POST',
            data: JSON.stringify({
                id: itemID,
                status: "ready"
            })
        })

        // Send response
        res.status(204).send(`${fileEvent.name} processed`);
    } catch (err) {
        console.log(`Error: creating the thumbnail: ${err}`);
        console.error(err);
        res.status(500).send(err);
    }
};