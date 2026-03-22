// ============================================================
// Part 2 — MongoDB Operations (mongo_queries.js)
// ============================================================
// Run in mongosh:
//   mongosh "mongodb://localhost:27017/ecommerce" --file mongo_queries.js
// Or interactively:
//   mongosh "mongodb://localhost:27017/ecommerce"
//   then paste each block
// ============================================================

use("ecommerce");

// ============================================================
// OP1: insertMany() — insert all 3 documents from sample_documents.json
// ============================================================
db.products.insertMany([
  {
    product_id: "ELEC-001",
    name: "Samsung 65-inch QLED 4K Smart TV",
    category: "Electronics",
    brand: "Samsung",
    price: 85000,
    currency: "INR",
    stock_quantity: 42,
    specifications: {
      display: {
        size_inches: 65,
        resolution: "3840x2160 (4K UHD)",
        panel_type: "QLED",
        refresh_rate_hz: 120,
        hdr_support: ["HDR10+", "HLG"]
      },
      connectivity: {
        hdmi_ports: 4,
        usb_ports: 2,
        wifi: "802.11ac dual-band",
        bluetooth: "5.2"
      },
      power: {
        voltage: "220-240V",
        power_consumption_watts: 190,
        standby_watts: 0.5
      },
      smart_features: {
        operating_system: "Tizen 7.0",
        voice_assistants: ["Bixby", "Alexa", "Google Assistant"],
        app_store: true
      }
    },
    warranty: {
      duration_years: 2,
      type: "Comprehensive",
      covers: ["Manufacturing defects", "Panel failure"],
      service_centers: ["Mumbai", "Delhi", "Bangalore", "Chennai", "Hyderabad"]
    },
    ratings: {
      average: 4.6,
      total_reviews: 1287
    },
    tags: ["4K", "QLED", "smart-tv", "samsung", "home-entertainment"],
    is_available: true,
    created_at: new Date("2024-01-10T09:00:00Z")
  },
  {
    product_id: "CLTH-001",
    name: "Raymond Men's Classic Fit Formal Shirt",
    category: "Clothing",
    brand: "Raymond",
    price: 1799,
    currency: "INR",
    stock_quantity: 215,
    specifications: {
      fabric: {
        composition: "100% Giza Cotton",
        weave: "Oxford",
        weight_gsm: 140
      },
      fit: "Classic Fit",
      collar_type: "Point Collar",
      sleeve_type: "Full Sleeve",
      care_instructions: [
        "Machine wash cold (30°C)",
        "Do not bleach",
        "Tumble dry low",
        "Iron on medium heat"
      ]
    },
    available_sizes: ["S", "M", "L", "XL", "XXL", "3XL"],
    available_colors: [
      { color_name: "White",      hex_code: "#FFFFFF", stock: 80 },
      { color_name: "Light Blue", hex_code: "#ADD8E6", stock: 75 },
      { color_name: "Light Grey", hex_code: "#D3D3D3", stock: 60 }
    ],
    target_gender: "Men",
    occasion: ["Formal", "Business", "Office"],
    certifications: ["OEKO-TEX Standard 100"],
    country_of_origin: "India",
    ratings: { average: 4.3, total_reviews: 563 },
    tags: ["formal", "cotton", "shirt", "office-wear", "raymond"],
    is_available: true,
    created_at: new Date("2024-01-12T11:00:00Z")
  },
  {
    product_id: "GROC-001",
    name: "Aashirvaad Organic Whole Wheat Flour (Atta) 10kg",
    category: "Groceries",
    brand: "Aashirvaad",
    price: 420,
    currency: "INR",
    stock_quantity: 530,
    specifications: {
      weight_kg: 10,
      grain_type: "Whole Wheat",
      milling_process: "Stone Ground",
      organic_certified: true,
      certification_body: "FSSAI",
      packaging_type: "Sealed Poly Bag with Zip Lock"
    },
    nutritional_info_per_100g: {
      calories_kcal: 340,
      protein_g: 12.0,
      total_carbohydrates_g: 71.2,
      dietary_fiber_g: 10.8,
      total_fat_g: 1.5,
      sodium_mg: 2
    },
    allergens: ["Wheat", "Gluten"],
    suitable_for: ["Vegetarian", "Vegan"],
    expiry: {
      manufacture_date: new Date("2024-10-01T00:00:00Z"),
      best_before_date: new Date("2025-04-01T00:00:00Z"),
      shelf_life_days: 180
    },
    storage_instructions: "Store in a cool, dry place away from direct sunlight.",
    country_of_origin: "India",
    ratings: { average: 4.7, total_reviews: 8921 },
    tags: ["atta", "flour", "organic", "whole-wheat", "staple", "vegan"],
    is_available: true,
    created_at: new Date("2024-01-08T07:30:00Z")
  }
]);

// ============================================================
// OP2: find() — retrieve all Electronics products with price > 20000
// Returns product_id, name, brand, price, and ratings
// ============================================================
db.products.find(
  {
    category: "Electronics",
    price: { $gt: 20000 }
  },
  {
    product_id: 1,
    name: 1,
    brand: 1,
    price: 1,
    "ratings.average": 1,
    _id: 0
  }
).sort({ price: -1 });

// ============================================================
// OP3: find() — retrieve all Groceries expiring before 2025-01-01
// Searches nested expiry.best_before_date field
// ============================================================
db.products.find(
  {
    category: "Groceries",
    "expiry.best_before_date": { $lt: new Date("2025-01-01T00:00:00Z") }
  },
  {
    product_id: 1,
    name: 1,
    "expiry.best_before_date": 1,
    "expiry.shelf_life_days": 1,
    price: 1,
    _id: 0
  }
);

// ============================================================
// OP4: updateOne() — add a "discount_percent" field to ELEC-001
// Adds discount_percent (10%) and computes discounted_price
// ============================================================
db.products.updateOne(
  { product_id: "ELEC-001" },
  {
    $set: {
      discount_percent: 10,
      discounted_price: 76500,
      discount_valid_until: new Date("2024-12-31T23:59:59Z")
    },
    $currentDate: { updated_at: true }
  }
);

// Verify the update
db.products.findOne(
  { product_id: "ELEC-001" },
  { name: 1, price: 1, discount_percent: 1, discounted_price: 1, _id: 0 }
);

// ============================================================
// OP5: createIndex() — create an index on the category field
//
// Reason: The `category` field is the most heavily used filter
// in all product queries (OP2 filters by "Electronics", OP3 by
// "Groceries"). Without an index, MongoDB performs a full
// collection scan (O(n)) for every query — unacceptable as the
// catalog grows to millions of SKUs. A B-tree index on `category`
// reduces lookup time to O(log n) and benefits compound queries
// like { category: "Electronics", price: { $gt: X } }.
// The `background: true` option builds the index without blocking
// read/write operations on the collection.
// ============================================================
db.products.createIndex(
  { category: 1 },
  { name: "idx_category", background: true }
);

// Additional useful index: compound index on category + price
// for range queries combining both fields
db.products.createIndex(
  { category: 1, price: -1 },
  { name: "idx_category_price", background: true }
);

// Verify indexes were created
db.products.getIndexes();
