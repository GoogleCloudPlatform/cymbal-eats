package org.google.demo;

import java.math.BigInteger;
import java.time.LocalDateTime;
import javax.persistence.Column;
import javax.persistence.Entity;

import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import io.quarkus.hibernate.orm.panache.PanacheEntity;

@Entity
public class Customer extends PanacheEntity {
    
    @Column(name="customer_email")
    public String customerEmail;

    @Column(name="customer_name")
    public String customerName;
    
    @Column(name="customer_address")
    public String customeraddress;

    @Column(name="customer_city")
    public String customerCity;

    @Column(name="customer_state")
    public String customerState;

    @Column(name="customer_zip")
    public String customerZIP;

    @Column(name="customer_reward_points")
    public BigInteger customerRewardPoints;

    @CreationTimestamp
    @Column(name="creation_timestamp")
    public LocalDateTime createDateTime;
 
    @UpdateTimestamp
    @Column(name="update_timestamp")
    public LocalDateTime updateDateTime;

    public static Customer findByEmail(String customerEmail) {
        return (find("customerEmail", customerEmail).firstResult());
    }

}
