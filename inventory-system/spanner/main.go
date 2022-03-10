// Copyright 2020 Google LLC
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
// Author ghaun@google.com
// Simple Cloud Run Service which connects with Spanner

package main

import (
	"context"
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"os"
	"regexp"
	"strings"
	"time"

	"github.com/google/uuid"

	"cloud.google.com/go/spanner"
	database "cloud.google.com/go/spanner/admin/database/apiv1"
	"google.golang.org/api/iterator"
	adminpb "google.golang.org/genproto/googleapis/spanner/admin/database/v1"
)

// TODO(GHAUN): Create global database variable and clean up code

// create Global Variable for Database
// Spanner connection ID should look like:
// projects/<PROJECT>/instances/<SPANNER INSTANCE>/databases/<database>

var databaseName string = os.Getenv("SPANNER_CONNECTION_STRING")
var dataClient *spanner.Client

func main() {
	log.Print("Starting server...")
	log.Print("Creating Database if it doesn't exist")
	err := createDatabase(databaseName)
	if err != nil {
		if !strings.Contains(err.Error(), "AlreadyExists") {
			log.Fatal(err)
		}
		log.Print("Database Already Created")
	}
	log.Print("Database setup complete")

	ctx := context.Background()

	dataClient, err = spanner.NewClient(ctx, databaseName)

	if err != nil {
		log.Fatal(err)
	}

	seedDatabase(databaseName)

	// Setup http Handles
	http.HandleFunc("/", handler)
	http.HandleFunc("/getAvailableInventory", getAvailableInventory)
	http.HandleFunc("/updateInventoryItem", updateInventoryItem)

	// Determine port for HTTP service.
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
		log.Printf("defaulting to port %s", port)
	}

	// Start HTTP server.
	log.Printf("listening on port %s", port)
	if err := http.ListenAndServe(":"+port, nil); err != nil {
		log.Fatal(err)
	}

	defer dataClient.Close()

}

func enableCors(w *http.ResponseWriter) {
	(*w).Header().Set("Access-Control-Allow-Origin", "*")
}

func handler(w http.ResponseWriter, r *http.Request) {
	enableCors(&w)
	fmt.Fprintf(w, "GoLang Inventory Service is running!")
}

func getAvailableInventory(w http.ResponseWriter, r *http.Request) {
	enableCors(&w)
	response, err := readAvailableInventory(databaseName)
	if err != nil {
		log.Fatal(err)
	}
	fmt.Fprint(w, response)
}

func updateInventoryItem(w http.ResponseWriter, r *http.Request) {
	enableCors(&w)
	if r.URL.Path != "/updateInventoryItem" {
		http.NotFound(w, r)
		return
	}
	switch r.Method {
	case "GET":
		w.Write([]byte("Please POST the following format for data:  [{'itemName': string,'inventoryChange': int}]"))
	case "POST":
		d := json.NewDecoder(r.Body)
		d.DisallowUnknownFields()
		il := []struct {
			ItemID          int `json:"itemID"`
			InventoryChange int `json:"inventoryChange"`
		}{}
		err := d.Decode(&il)
		if err != nil {
			log.Print(err)
			return
		}
		// In production code you should check and sanatize data. This is a demo however

		log.Print(il)
		// This should be a global variable since it's used more than once
		inventoryHistoryColumns := []string{
			"ItemRowID",
			"ItemID",
			"inventoryChange",
			"timeStamp"}
		m := []*spanner.Mutation{}
		for _, element := range il {
			m = append(m, spanner.Insert(
				"inventoryHistory",
				inventoryHistoryColumns,
				[]interface{}{uuid.New().String(), element.ItemID, element.InventoryChange, time.Now()}))
		}
		_, err = dataClient.Apply(context.Background(), m)
		if err != nil {
			log.Print(err)
			return
		}
		log.Print("Data added to database")
		w.Write([]byte(http.StatusText(http.StatusOK)))

	default:
		w.WriteHeader(http.StatusNotImplemented)
		w.Write([]byte(http.StatusText(http.StatusNotImplemented)))
	}
}

func createDatabase(db string) error {
	ctx := context.Background()
	matches := regexp.MustCompile("^(.*)/databases/(.*)$").FindStringSubmatch(db)
	if matches == nil || len(matches) != 3 {
		return fmt.Errorf("invalid database id %s", db)
	}

	adminClient, err := database.NewDatabaseAdminClient(ctx)
	if err != nil {
		return err
	}
	defer adminClient.Close()
	log.Print("Creating Database and table")
	op, err := adminClient.CreateDatabase(ctx, &adminpb.CreateDatabaseRequest{
		Parent:          matches[1],
		CreateStatement: "CREATE DATABASE `" + matches[2] + "`",
		ExtraStatements: []string{
			`CREATE TABLE InventoryHistory (
				ItemRowID STRING (36) NOT NULL,
				ItemID	INT64 NOT NULL,
				InventoryChange  INT64,
				TimeStamp   TIMESTAMP,
			) PRIMARY KEY (ItemRowID)`,
		},
	})
	if err != nil {
		return err
	}
	if _, err := op.Wait(ctx); err != nil {
		return err
	}
	return nil
}

func seedDatabase(db string) error {
	// Need to count rows here and only seed if rows exist
	rows, _ := readAvailableInventory(databaseName)
	if rows != "[]" {
		log.Print("Database has already been seeded")
		return nil
	}
	log.Print("Seeding Database")

	// Get JSON file here for seeding
	// Use test for now
	inventoryHistoryColumns := []string{
		"ItemRowID",
		"ItemID",
		"InventoryChange",
		"TimeStamp"}
	m := []*spanner.Mutation{
		spanner.Insert("inventoryHistory", inventoryHistoryColumns, []interface{}{uuid.New().String(), 1, "5", time.Now()}),
		spanner.Insert("inventoryHistory", inventoryHistoryColumns, []interface{}{uuid.New().String(), 2, "3", time.Now()}),
		spanner.Insert("inventoryHistory", inventoryHistoryColumns, []interface{}{uuid.New().String(), 3, "1", time.Now()}),
	}
	_, err := dataClient.Apply(context.Background(), m)
	if err != nil {
		return err
	}

	return nil
}

func readAvailableInventory(db string) (string, error) {

	ro := dataClient.ReadOnlyTransaction()
	defer ro.Close()
	stmt := spanner.Statement{
		SQL: `SELECT 
		itemID,
		sum(inventoryChange) as inventory 
		FROM inventoryHistory 
		group by ItemID`}
	iter := ro.Query(context.Background(), stmt)
	defer iter.Stop()
	type inventoryList struct {
		ItemID    int64
		Inventory int64
	}
	itemList := []inventoryList{}
	for {
		row, err := iter.Next()
		if err == iterator.Done {
			break
		}
		if err != nil {
			return "", err
		}
		item := inventoryList{}
		if err := row.Columns(&item.ItemID, &item.Inventory); err != nil {
			return "", err
		}
		itemList = append(itemList, item)
	}
	j, err := json.Marshal(itemList)
	if err != nil {
		return "", err
	} else {
		return string(j), err
	}
}
