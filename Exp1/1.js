// CRUD operations on an array

let items = []; // our array

// Create - add item
function createItem(item) {
  items.push(item);
  console.log(`${item} added!`);
}

// Read - display all items
function readItems() {
  if (items.length === 0) {
    console.log("No items found.");
  } else {
    console.log("Items:", items);
  }
}

// Update - change item at a specific index
function updateItem(index, newItem) {
  if (index >= 0 && index < items.length) {
    console.log(`Updated ${items[index]} to ${newItem}`);
    items[index] = newItem;
  } else {
    console.log("Invalid index.");
  }
}

// Delete - remove item at a specific index
function deleteItem(index) {
  if (index >= 0 && index < items.length) {
    console.log(`Deleted: ${items[index]}`);
    items.splice(index, 1);
  } else {
    console.log("Invalid index.");
  }
}

// Example usage:
createItem("Apple");
createItem("Banana");
createItem("Orange");

readItems(); // Show items

updateItem(1, "Mango"); // Replace Banana with Mango
readItems();

deleteItem(0); // Delete Apple
readItems();
