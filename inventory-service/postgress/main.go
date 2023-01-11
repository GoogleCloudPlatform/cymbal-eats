// Copyright 2023 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

// Author ghaun@google.com
// Simple Cloud Run service which connects to Postgres backend.

package main

import (
	"encoding/json"
	"errors"
	"fmt"
	"log"
	"net/http"
	"os"
	"time"

	"gorm.io/driver/postgres"
	"gorm.io/gorm"
)

// Create inventory Model in database
type inventoryItem struct {
	gorm.Model
	ItemName        string
	InventoryChange int
	TimeStamp       time.Time
}

// create Global Variable for Database

var db = new(gorm.DB)

func main() {
	log.Print("tarting server...")
	dbUser := os.Getenv("DB_USER")
	dbPassword := os.Getenv("DB_PASSWORD")
	dbHost := os.Getenv("DB_HOST")
	dbName := os.Getenv("DB_NAME")

	log.Print("Connecting to DB")
	var err error
	db, err = gorm.Open(postgres.New(postgres.Config{
		DSN: fmt.Sprintf("host=%s user=%s password=%s dbname=%s", dbHost, dbUser, dbPassword, dbName),
	}))
	if err != nil {
		log.Fatal(err)
	}
	log.Print("Database Connected, Migrating Schema(s)")
	// In production you probably want this in your build pipeline. Not on app startup
	err = db.AutoMigrate(&inventoryItem{})
	if err != nil {
		log.Fatal(err)
	}
	log.Print("Database Migration Complete")

	// Seed database so we have fake data
	seedDatabase()

	// Setup http Handles
	http.HandleFunc("/", handler)
	http.HandleFunc("/getAvailableInventory", getAvailableInventory)

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

}

func handler(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintf(w, "GoLang Inventory Service is running!")
}

func getAvailableInventory(w http.ResponseWriter, r *http.Request) {
	type inventoryList struct {
		Item_name string
		Inventory int
	}
	rows, err := db.Model(&inventoryItem{}).Select("item_name as Item_Name", "sum(inventory_change) as Inventory").Group("item_name").Rows()
	if err != nil {
		log.Print(err)
	} else {
		itemList := []inventoryList{}
		for rows.Next() {
			db.ScanRows(rows, &itemList)
		}
		j, err := json.Marshal(itemList)
		if err != nil {
			log.Fatal(err)
		} else {
			fmt.Fprint(w, string(j))
		}
	}
}

func seedDatabase() {
	var it inventoryItem
	result := db.First(&it)
	// Let's check if records exist
	if errors.Is(result.Error, gorm.ErrRecordNotFound) {
		// If no records exist, let's seed the database
		// Load CSV file here and add to database
		// This is a temp line to get rid of warnings
		log.Print("Seeding Database")
		newItem := inventoryItem{
			ItemName:        "Testing",
			InventoryChange: 5,
			TimeStamp:       time.Now(),
		}
		db.Create(&newItem)
		newItem = inventoryItem{
			ItemName:        "Testing",
			InventoryChange: -3,
			TimeStamp:       time.Now(),
		}
		db.Create(&newItem)
	}
}
