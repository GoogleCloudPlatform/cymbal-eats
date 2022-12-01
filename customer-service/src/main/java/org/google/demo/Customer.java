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
