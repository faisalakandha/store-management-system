#!/bin/bash

DATABASE="store.db"

# Function to display the main menu
function display_menu() {
    echo "========== Store Management System =========="
    echo "1. Add Product"
    echo "2. Sell Product"
    echo "3. Update Existing Products"
    echo "4. Search Products"
    echo "5. Add Supplier Information"
    echo "6. Delete Products"
    echo "7. Categorize Products"
    echo "8. View Inventory"
    echo "9. Generate Sales Report"
    echo "10. Exit"
    echo "============================================"
}

# Function to add a new product to the inventory
function add_product() {
    echo "========== Add Product =========="
    read -p "Enter product name: " name
    read -p "Enter product quantity: " quantity
    read -p "Enter product price: " price

    sqlite3 $DATABASE <<EOF
   INSERT INTO products (name, quantity, price)
   VALUES ("$name", $quantity, $price);
EOF

    echo "Product added successfully!"
}

# Function to sell a product and update inventory
function sell_product() {
    echo "========== Sell Product =========="
    read -p "Enter product ID: " product_id
    read -p "Enter quantity to sell: " quantity

    sqlite3 $DATABASE <<EOF
   SELECT * FROM products WHERE id = $product_id;
EOF

    if [[ $? -ne 0 ]]; then
        echo "Product not found!"
        return
    fi

    sqlite3 $DATABASE <<EOF
   SELECT quantity FROM products WHERE id = $product_id;
EOF

    current_quantity=$(sqlite3 $DATABASE "SELECT quantity FROM products WHERE id = $product_id;")
    if [[ $current_quantity -lt $quantity ]]; then
        echo "Insufficient quantity in inventory!"
        return
    fi

    total_price=$(sqlite3 $DATABASE "SELECT price FROM products WHERE id = $product_id;")*$quantity

    sqlite3 $DATABASE <<EOF
   INSERT INTO sales (product_id, quantity, total_price, sale_date)
   VALUES ($product_id, $quantity, $total_price, date('now'));
EOF

    sqlite3 $DATABASE <<EOF
   UPDATE products SET quantity = quantity - $quantity WHERE id = $product_id;
EOF

    echo "Product sold successfully!"
}

# Function to update existing product details
function update_product() {
    echo "========== Update Existing Product =========="
    read -p "Enter product ID: " product_id
    read -p "Enter new product name: " name
    read -p "Enter new product quantity: " quantity
    read -p "Enter new product price: " price

    sqlite3 $DATABASE <<EOF
   UPDATE products SET name = "$name", quantity = $quantity, price = $price WHERE id = $product_id;
EOF

    echo "Product updated successfully!"
}

# Function to search for products
function search_product() {
    echo "========== Search Products =========="
    read -p "Enter search keyword: " keyword

    sqlite3 $DATABASE <<EOF
   SELECT * FROM products WHERE name LIKE '%$keyword%';
EOF
}

# Function to add supplier information for a product
function add_supplier_info() {
    echo "========== Add Supplier Information =========="
    read -p "Enter product ID: " product_id
    read -p "Enter supplier name: " supplier_name
    read -p "Enter supplier contact: " supplier_contact

    sqlite3 $DATABASE <<EOF
   UPDATE products SET supplier_name = "$supplier_name", supplier_contact = "$supplier_contact" WHERE id = $product_id;
EOF

    echo "Supplier information added successfully!"
}

# Function to delete a product
function delete_product() {
    echo "========== Delete Product =========="
    read -p "Enter product ID: " product_id

    sqlite3 $DATABASE <<EOF
   DELETE FROM products WHERE id = $product_id;
EOF

    echo "Product deleted successfully!"
}

# Function to categorize products
function categorize_products() {
    echo "========== Categorize Products =========="
    read -p "Enter product ID: " product_id
    read -p "Enter product category: " category

    sqlite3 $DATABASE <<EOF
   UPDATE products SET category = "$category" WHERE id = $product_id;
EOF

    echo "Product categorized successfully!"
}

# Function to view the inventory
function view_inventory() {
    echo "========== Inventory =========="
    sqlite3 $DATABASE "SELECT * FROM products;"
}

# Function to generate a sales report
function generate_sales_report() {
    echo "========== Sales Report =========="
    sqlite3 $DATABASE "SELECT sales.id, products.name, sales.quantity, sales.total_price, sales.sale_date
                    FROM sales INNER JOIN products ON sales.product_id = products.id;"
}

# Main loop
while true; do
    display_menu
    read -p "Enter your choice: " choice

    case $choice in
    1)
        add_product
        ;;
    2)
        sell_product
        ;;
    3)
        update_product
        ;;
    4)
        search_product
        ;;
    5)
        add_supplier_info
        ;;
    6)
        delete_product
        ;;
    7)
        categorize_products
        ;;
    8)
        view_inventory
        ;;
    9)
        generate_sales_report
        ;;
    10)
        echo "Exiting..."
        exit 0
        ;;
    *)
        echo "Invalid choice. Please try again."
        ;;
    esac

    echo
done
