# E-Commerce Product Management App

A Flutter application for managing product listings on an e-commerce platform. This app allows users to add, view, update, and delete products, with filtering options based on category and favorite status. Users can also add reviews to products with ratings.

## Key Features

- **Product Management**: Create, view, update, and delete products.
- **Category Management**: Select from existing categories or create a new one to organize products.
- **Favorite Feature**: Users can mark products as favorites and filter the list to show only favorites.
- **Review System**: Users can add, edit, and delete reviews for each product, including a rating.
- **Filtering**: Filter the product list based on category and favorite status.

## Tech Stack

- **Flutter**: Cross-platform UI toolkit.
- **SQLite**: Local database for storing product, category, and review information.
- **Stateful Widgets**: Manage the state of product and review pages.

## Project Structure

```plaintext
.
├── lib/
│   ├── db_helper.dart              # Database helper for SQLite operations
│   ├── home_page.dart              # Main page displaying product list and filters
│   ├── product_detail_page.dart    # Product detail page for managing products and reviews
│   ├── models/
│   │   ├── product.dart            # Product model
│   │   ├── category.dart           # Category model
│   │   └── review.dart             # Review model
└── README.md                       # Project documentation
```

## Installation and Running the App

1. Clone this repository to your local machine:

```bash
git clone https://github.com/Aquabet/e-commerce-platform.git
cd e-commerce-platform
```

2. Ensure you have Flutter installed, then get the dependencies:

```bash
flutter pub get
```

3. Run the app:

```bash
flutter run
```

## Usage Guide

### Home Page

- The home page displays all products, with an "Add" button at the top to create a new product.
- Use the category dropdown and "Only Favorites" checkbox to filter the product list.

### Product Detail Page

- In the product detail page, users can:
  - Add or Edit Product: Set the product name, price, and select or create a category.
  - Select Category: Choose from existing categories in a dropdown or type in a new category name to create a new one.
  - Favorite Product: Toggle the heart icon at the top to mark a product as favorite.
  - Manage Reviews: Add a review with a rating, edit, or delete reviews for the product.

### Database Schema

- Product: Stores `id`, `name`, `price`, `category_id`, and `is_favorite` fields.
- Category: Stores `id` and `name` fields.
- Review: Stores `id`, `product_id`, `review_text`, and `rating` fields.

## Notes

- SQLite Database: This project uses SQLite for local storage. Database operations are managed through - the db_helper.dart file, which includes CRUD methods for products, categories, and reviews.
- Dependencies: Ensure the Flutter SDK is properly installed for successful app building and running.

## Future Enhancements

- User Authentication: Add login and registration functionality to allow users to manage their own favorites and reviews.
- Online Sync: Add server API support to sync local and remote database data for cross-device accessibility.
- Advanced Filtering: Implement additional filters based on product price or rating.

## Contributing

Pull requests and issue reports are welcome to help improve this project. Feel free to reach out with suggestions or questions.
