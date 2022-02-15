package org.google.demo;

import java.util.List;

import javax.transaction.Transactional;
import javax.ws.rs.Consumes;
import javax.ws.rs.DELETE;
import javax.ws.rs.GET;
import javax.ws.rs.POST;
import javax.ws.rs.PUT;
import javax.ws.rs.Path;
import javax.ws.rs.PathParam;
import javax.ws.rs.Produces;
import javax.ws.rs.WebApplicationException;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;

import io.quarkus.panache.common.Sort;

@Path ("/menu")
@Consumes(MediaType.APPLICATION_JSON)
@Produces(MediaType.APPLICATION_JSON)
public class MenuResource {

    private Long id;

    @GET
    public List<Menu> getAll() throws Exception {

        return Menu.findAll(Sort.ascending("item_name")).list();
        
    }

    @POST
    @Transactional
    public Response create(Menu menu) {
        if (menu == null || menu.id != null) 
            throw new WebApplicationException("id != null");
        menu.persist();
        return Response.ok(menu).status(200).build();
    }

    @PUT
    @Transactional
    @Path("{id}")
    public Menu update(@PathParam("id") Long id, Menu menu) {

        Menu entity = Menu.findById(id);
        if (entity == null) {
            throw new WebApplicationException("Menu item with id"+id+"does not exist", 404);
        }

        if (menu.itemName != null) entity.itemName=menu.itemName;
        if (menu.itemPrice != null) entity.itemPrice=menu.itemPrice;
        if (menu.tagLine != null) entity.tagLine=menu.tagLine;
        entity.spiceLevel=menu.spiceLevel;
        if (menu.itemImageURL != null) entity.itemImageURL = menu.itemImageURL;

        return entity;
    }

    @DELETE
    @Path("{id}")
    @Transactional
    public Response delete(@PathParam("id") Long id) {
        Menu entity = Menu.findById(id);
        if (entity == null) {
            throw new WebApplicationException("Menu item with id"+id+"does not exist", 404);
        }
        entity.delete();
        return Response.status(204).build();
    }


}
