# 🏡 Desi Lynks

Desi Lynks is a premium Flutter mobile application designed for renting rooms, apartments, houses, and studios, as well as finding local community listings, jobs, and marketplace deals.

The application is built using modern development best practices including **MVVM Architecture**, state management via **Provider**, and clean separation of concerns.

---

## ✨ Features

### 1. Advanced Property Filters & Search

* **Stateless Filters Screen**: Built as a pure `StatelessWidget` integrated with `Provider` to split **applied** filters from **temporary** selections during customization.
* **Context-Aware Room Capsule Filters**: Intelligently separates `ROOM` types into *Private Room* or *Shared Room* categories by scanning listing metadata (titles and descriptions) in real time.
* **Range & Sorting Customizations**: Support for location checks, distance ranges, max rent budgets, and sort criteria such as *Newest First*, *Price: Low-High*, *Price: High-Low*, and *Most Popular* (based on view counts).
* **Live Search**: Integrated text query search bar in the listings catalog view that filters results instantly by title or location.

### 2. Room Posting Wizard & Local Drafts

* **Animated Progress Bar**: Features a smooth `TweenAnimationBuilder` that dynamically shifts step progress (Step 1 to 3) as the property owner inputs form details.
* **Smart Draft Saving**: Persists draft posts locally in memory, bypassing backend API status validations to guarantee that incomplete posts can always be resumed in the "Pending" tab.

### 3. Rich Home Screen

* Modular UI elements featuring Categories Grid, Explore Spain tours, featured properties, today's platform statistics, and community spotlights.
* Styling tokens and strings decoupled into `AppColors`, `AppStrings`, and `AppConstants` for global design consistency.

---

## 🛠 Tech Stack

* **Frontend**: [Flutter](https://flutter.dev/) (Dart)
* **State Management**: [Provider](https://pub.dev/packages/provider)
* **Networking**: HTTP client with custom headers validation and logging wrapper
* **Local Storage**: `SharedPreferences` for user session and profile persistence
* **Assets**: Custom SVG assets and Unsplash image placeholders

---

## 📂 Project Structure

```text
lib/
├── app/
│   ├── routes.dart                # Page route declarations and custom page transition definitions
│   └── app.dart                  # Main application MaterialApp runner
├── core/
│   ├── constants/
│   │   ├── app_colors.dart        # Semantic color tokens and slate/blue palettes
│   │   ├── app_constants.dart     # Sizing, margins, border radii, and padding variables
│   │   ├── app_strings.dart       # Localized strings, labels, and helper texts
│   │   ├── app_icons.dart         # SVG and asset paths
│   │   └── app_opacities.dart     # Centralized transparency and opacity tokens
├── models/
│   ├── property_model.dart        # Unified backend data model for properties
│   └── room_post.dart             # Local data model representation for drafts
├── repositories/
│   └── property_repository.dart   # Core gateway for REST endpoints GET/POST property
├── services/
│   └── api/
│       ├── api_endpoints.dart     # Base URL and path constants
│       └── api_service.dart       # Network client with token inject helpers
├── viewmodels/
│   └── create_post/
│       └── post_room_viewmodel.dart # MVVM controller for posting progress, filters, and drafts
└── views/
    ├── home/                      # Browse dashboard containing modular sub-widgets
    ├── create_post/
    │   └── rooms/
    │       ├── post_room_view.dart       # Multi-step property publisher page
    │       ├── room_details_view.dart    # Properties feed listing with search/filter
    │       ├── filters_view.dart         # Advanced search parameters options modal
    │       └── room_single_details_view.dart # Expanded property details overview page
    └── profile/                   # Public profiles and listing manager views
```

---

## 🚀 Getting Started

### Prerequisites

* Flutter SDK (v3.0.0 or higher)
* Dart SDK (v3.0.0 or higher)

### Installation

1. **Clone the repository**:

   ```bash
   git clone <repository-url>
   cd dessi_connect
   ```

2. **Retrieve dependencies**:

   ```bash
   flutter pub get
   ```

3. **Verify compiler correctness**:

   ```bash
   flutter analyze
   ```

4. **Launch the application**:

   ```bash
   flutter run
   ```
