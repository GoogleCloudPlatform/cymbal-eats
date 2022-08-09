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

@Path ("/customer")
@Consumes(MediaType.APPLICATION_JSON)
@Produces(MediaType.APPLICATION_JSON)
public class CustomerResource {


    @GET
    public List<Customer> getAll() throws Exception {

        return Customer.findAll(Sort.ascending("customer_name")).list();

    }

    @GET
    @Path("{id}")
    public Customer get(@PathParam("id") Long id) throws Exception {
        return Customer.findById(id);
    }

    @POST
    @Path("/exists")
    public Response exists(Customer customer) {
        if (customer.email == null)
            throw new WebApplicationException("email is null");

        Customer existingCustomer = Customer.findByEmail(customer.email);

        if (existingCustomer == null)
            return Response.ok(customer).status(200).build();

        return Response.ok(existingCustomer).status(200).build();
    }

    @POST
    @Transactional
    public Response create(Customer customer) {
        if (customer == null || customer.id != null)
            throw new WebApplicationException("id != null");
        if (Customer.findByEmail(customer.email)!=null)
            throw new WebApplicationException("Customer already exists!");
        customer.persist();
        return Response.ok(customer).status(200).build();
    }

    @PUT
    @Transactional
    @Path("{id}")
    public Customer update(@PathParam("id") Long id, Customer customer) {

        Customer entity = Customer.findById(id);
        if (entity == null) {
            throw new WebApplicationException("Customer with id"+id+"does not exist", 404);
        }

        if (customer.name != null) entity.name=customer.name;
        if (customer.address != null) entity.address=customer.address;
        if (customer.city != null) entity.city=customer.city;
        if (customer.state != null) entity.state = customer.state;
        if (customer.zip != null) entity.zip = customer.zip;
        if (customer.rewardPoints != null) entity.rewardPoints = customer.rewardPoints;

        return entity;
    }

    @DELETE
    @Path("{id}")
    @Transactional
    public Response delete(@PathParam("id") Long id) {
        Customer entity = Customer.findById(id);
        if (entity == null) {
            throw new WebApplicationException("Customer with id"+id+"does not exist", 404);
        }
        entity.delete();
        return Response.status(204).build();
    }


}
