#!/usr/bin/env bash

# Copyright 2023 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

source config-env.sh

export BASE_DIR=$PWD

cd ${BASE_DIR}/menu-service
./setup.sh
cd $BASE_DIR

cd ${BASE_DIR}/inventory-service/spanner
./setup.sh
cd $BASE_DIR

cd ${BASE_DIR}/order-service
./setup.sh
cd $BASE_DIR

cd ${BASE_DIR}/cloud-functions
./setup.sh
cd $BASE_DIR

cd ${BASE_DIR}/cleanup-service
./setup.sh
cd $BASE_DIR

cd ${BASE_DIR}/customer-service
./setup.sh
cd $BASE_DIR

cd ${BASE_DIR}/employee-ui
./setup.sh
cd $BASE_DIR

cd ${BASE_DIR}/customer-ui
./setup.sh
cd $BASE_DIR