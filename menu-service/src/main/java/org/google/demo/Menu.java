package org.google.demo;

import java.math.BigDecimal;
import java.net.URL;
import java.time.LocalDateTime;
import java.util.List;

import javax.persistence.Column;
import javax.persistence.Entity;

import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

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

    @Column(name="item_thumbnail_url")
    public URL itemThumbnailURL;

    @Column(name="item_status")
    public Status status;

    @CreationTimestamp
    @Column(name="creation_timestamp")
    public LocalDateTime createDateTime;
 
    @UpdateTimestamp
    @Column(name="update_timestamp")
    public LocalDateTime updateDateTime;

    public static List<Menu> findReady() {
        return list("status", Status.Ready);
    }
    
    public static List<Menu> findFailed() {
        return list("status", Status.Failed);
    }

    public static List<Menu> findProcessing() {
        return list("status", Status.Processing);
    }
}
