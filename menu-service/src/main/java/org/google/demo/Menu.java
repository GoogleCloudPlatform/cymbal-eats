package org.google.demo;

import java.math.BigDecimal;
import java.net.URL;

import javax.persistence.Column;
import javax.persistence.Entity;

import io.quarkus.hibernate.orm.panache.PanacheEntity;

@Entity
public class Menu extends PanacheEntity {
    
    @Column(name="item_name")
    public String itemName;
    
    @Column(name="item_price")
    public BigDecimal itemPrice;

    @Column(name="default_spice_level", columnDefinition =  "integer default 0")
    public int spiceLevel;

    @Column(name="tag_line")
    public String tagLine; //"sweets delight", "super spicy"

    @Column(name="item_image_url")
    public URL itemImageURL;
     
}
