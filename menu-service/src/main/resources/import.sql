-- Copyright 2023 Google LLC
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
--      http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.

insert into menu(id, item_name, item_price, default_spice_level, tag_line, item_image_url, item_thumbnail_url, item_status) values (nextval('hibernate_sequence'), 'Curry Plate', 12.5, 3, 'Spicy touch for your taste buds!!' , 'https://unsplash.com/photos/0wn-DdavPa4', 'https://unsplash.com/photos/0wn-DdavPa4', 1);
insert into menu(id, item_name, item_price, default_spice_level, tag_line,  item_image_url, item_thumbnail_url, item_status) values (nextval('hibernate_sequence'), 'Full Meal in Banana Leaf', 20.25, 2, 'South Indian delight!!', 'https://unsplash.com/photos/yCIcDyKm440', 'https://unsplash.com/photos/yCIcDyKm440',1);
insert into menu(id, item_name, item_price, default_spice_level, tag_line,  item_image_url, item_thumbnail_url, item_status) values (nextval('hibernate_sequence'), 'Gulab Jamoon', 2.40, 0, 'Sweet cottage cheese dumplings', 'https://images.freeimages.com/images/large-previews/095/gulab-jamun-1637925.jpg','https://images.freeimages.com/images/large-previews/095/gulab-jamun-1637925.jpg',2);