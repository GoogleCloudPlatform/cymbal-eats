/*
 * Copyright 2023 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package org.google.demo;

import java.math.BigInteger;
import java.time.LocalDateTime;
import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Id;

import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import io.quarkus.hibernate.orm.panache.PanacheEntityBase;

@Entity
public class Customer extends PanacheEntityBase {

    @Id
    public String id;

    @Column(name="customer_email")
    public String email;

    @Column(name="customer_name")
    public String name;

    @Column(name="customer_address")
    public String address;

    @Column(name="customer_city")
    public String city;

    @Column(name="customer_state")
    public String state;

    @Column(name="customer_zip")
    public String zip;

    @Column(name="customer_reward_points")
    public BigInteger rewardPoints;

    @CreationTimestamp
    @Column(name="creation_timestamp")
    public LocalDateTime createDateTime;

    @UpdateTimestamp
    @Column(name="update_timestamp")
    public LocalDateTime updateDateTime;

    public static Customer findByEmail(String email) {
        return (find("email", email).firstResult());
    }

}
