# Flutter API Documentation: Desi Connect Search Module

This guide is designed for Flutter developers to seamlessly integrate the search functionalities into the application. The Search API provides full-text searching with typo tolerance, advanced filtering, pagination, sorting, and autocomplete suggestions.

---

## 1. Global Concepts & Response Format

All search endpoints (`GET` requests) support pagination and sorting out of the box and return a standardized JSON structure.

### **Server Base URL**
*   **Staging / Dev:** `https://dev.desilynks.com`
*   **Admin Panel:** `https://desicon-admin.evermontech.com`

### **Common Query Parameters for Pagination & Sorting**
| Parameter | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `page` | `int` | `1` | The page number to retrieve. |
| `limit` | `int` | `10` | Number of items per page. |
| `sortBy` | `String` | `'createdAt'` | The field to sort results by. |
| `sortOrder` | `String` | `'desc'` | The sort direction (`'asc'` or `'desc'`). |
| `query` | `String` | `null` | The free-text search string (e.g. "Room in Madrid", "Software Engineer"). |

### **Standard Response Object**
When parsing in Dart, the response will look like this:
```json
{
  "data": [
    {
      "_id": "uuid-string-here",
      "_score": 3.42, 
      "title": "...",
      // ... plus all other model specific fields ...
    }
  ],
  "meta": {
    "total": 45,
    "page": 1,
    "limit": 10,
    "totalPages": 5
  }
}
```
> [!TIP]
> The `_score` field in the data object indicates the relevance of the search result. Higher is better. 

---

## 2. Search Endpoints

### 2.1 Properties Search
**Endpoint:** `GET /search/properties`

**Available Query Parameters:**
*   `query` (String): Search by title, description, or location.
*   `type` (String Enum): e.g., `'APARTMENT'`, `'HOUSE'`, `'ROOM'`
*   `status` (String Enum): e.g., `'AVAILABLE'`, `'RENTED'`, `'PUBLISHED'`
*   `contactPreference` (String Enum): e.g., `'PHONE'`, `'EMAIL'`, `'CHAT'`
*   `minRent` (double)
*   `maxRent` (double)
*   `minBedrooms` (int)
*   `minBathrooms` (int)
*   `billsIncluded` (bool): Passed as `'true'` or `'false'`.
*   `location` (String): Exact match for location (used if `query` is empty).

**Example Dart Request (using `http` package):**
```dart
final uri = Uri.parse('https://dev.desilynks.com/search/properties').replace(
  queryParameters: {
    'query': 'Room',
    'type': 'ROOM',
    'page': '1',
    'limit': '10',
  }
);
final response = await http.get(uri);
```

**Real API Response Example (Verified Live):**
```json
{
  "data": [
    {
      "_id": "3a5a4c17-d7ec-4387-ae4a-6b1f6298587b",
      "_score": null,
      "id": "3a5a4c17-d7ec-4387-ae4a-6b1f6298587b",
      "ownerId": "3b1e8e1c-5e16-44d9-8301-db4285185c4c",
      "type": "ROOM",
      "title": "Room ff",
      "description": "fhdhsn",
      "status": "PUBLISHED",
      "monthlyRent": "300",
      "availableFrom": "2026-10-23T00:00:00.000Z",
      "location": "jdhdy",
      "noOfBedRooms": 2,
      "noOfBathRooms": 2,
      "contactPreference": "CHAT",
      "propertyPhotos": [
        {
          "id": "db17d0a7-9769-434d-80e2-e6748c15da44",
          "url": "/uploads/property-photos/879c8042-4197-4534-a82b-6cd7a1a8ed71.webp"
        }
      ]
    }
  ],
  "meta": {
    "total": 2,
    "page": 1,
    "limit": 10,
    "totalPages": 1
  }
}
```

---

### 2.2 Jobs Search
**Endpoint:** `GET /search/jobs`

**Available Query Parameters:**
*   `query` (String): Search by title, description, company name, skills, or location.
*   `category` (String Enum): e.g., `'IT'`, `'FINANCE'`
*   `type` (String Enum): e.g., `'FULL_TIME'`, `'PART_TIME'`, `'CONTRACT'`
*   `workMode` (String Enum): e.g., `'REMOTE'`, `'ONSITE'`, `'HYBRID'`
*   `experience` (String Enum): e.g., `'ENTRY_LEVEL'`, `'MID_LEVEL'`, `'TWO_PLUS_YEARS'`
*   `education` (String Enum): e.g., `'BACHELORS'`, `'MASTERS'`
*   `salaryPeriod` (String Enum): e.g., `'PER_MONTH'`, `'PER_YEAR'`, `'PER_HOUR'`
*   `status` (String Enum): e.g., `'OPEN'`, `'CLOSED'`
*   `minSalary` (double): Filters jobs where `maxSalary >= minSalary` input.
*   `maxSalary` (double): Filters jobs where `minSalary <= maxSalary` input.
*   `location` (String): Exact match.

**Real API Response Example (Verified Live):**
```json
{
  "data": [
    {
      "_id": "84288a2d-e5d5-49d7-9910-95149748c617",
      "_score": null,
      "id": "84288a2d-e5d5-49d7-9910-95149748c617",
      "employerId": "3b1e8e1c-5e16-44d9-8301-db4285185c4c",
      "title": "Lectureer",
      "companyName": "bdnd",
      "salary": "2000",
      "salaryPeriod": "PER_MONTH",
      "type": "FULL_TIME",
      "workMode": "ONSITE",
      "location": "dygdge",
      "status": "OPEN"
    }
  ],
  "meta": {
    "total": 1,
    "page": 1,
    "limit": 10,
    "totalPages": 1
  }
}
```

---

### 2.3 Worker Profiles Search
**Endpoint:** `GET /search/worker-profiles`

**Available Query Parameters:**
*   `query` (String): Search by the 'about' section or 'areaCovered'.
*   `service` (String Enum): The specific service the worker provides (e.g. `'ELECTRICIAN'`, `'PLUMBER'`, `'CLEANER'`).
*   `isAvailableToday` (bool): Passed as `'true'` or `'false'`.
*   `ownVehicle` (bool): Passed as `'true'` or `'false'`.
*   `ownTools` (bool): Passed as `'true'` or `'false'`.
*   `maxHourlyRate` (double)
*   `maxDailyRate` (double)
*   `minExperienceYears` (int)
*   `areaCovered` (String)

**Real API Response Example (Verified Live):**
```json
{
  "data": [
    {
      "_id": "a14e9855-5cd8-4ce7-84d7-647145910ef2",
      "_score": null,
      "id": "a14e9855-5cd8-4ce7-84d7-647145910ef2",
      "workerId": "3b1e8e1c-5e16-44d9-8301-db4285185c4c",
      "service": "ELECTRICIAN",
      "experienceInYears": 3,
      "hourlyRate": "200",
      "dailyRate": "10",
      "languagesSpoken": ["ENGLISH", "URDU", "HINDI"],
      "isAvailableToday": true,
      "ownVehicle": true,
      "ownTools": true,
      "areaCovered": "zgvzh",
      "about": "zisjz"
    }
  ],
  "meta": {
    "total": 1,
    "page": 1,
    "limit": 10,
    "totalPages": 1
  }
}
```

---

## 3. Autocomplete / Suggestions API

This endpoint is heavily optimized for keystroke-by-keystroke querying.

**Endpoint:** `GET /search/suggest`

**Query Parameters:**
| Parameter | Type | Required | Default | Description |
| :--- | :--- | :--- | :--- | :--- |
| `query` | `String` | **Yes** | - | The partial text typed by the user. |
| `index` | `String` | No | `'properties'` | Valid values: `'properties'`, `'jobs'`, `'worker_profiles'`. |
| `field` | `String` | No | `'title'` | The specific field to autocomplete against (e.g., `'title'`, `'companyName'`, `'service'`). |
| `size` | `int` | No | `5` | Maximum number of suggestions to return. |

**Live Request Example:**
`GET /search/suggest?query=Room&index=properties`
```json
{
  "suggestions": [
    "Room 22",
    "Room ff"
  ]
}
```

---

## 4. Flutter Integration Architecture (MVVM)

In the DesiLynks Flutter codebase, the search module is organized as follows:

1. **`SearchRepository` (`lib/repositories/search_repository.dart`):**
   - Handles network queries with `_buildQuery` for clean query string construction.
   - Flexible payload extractor (`_extractList`) supporting diverse JSON structures.
   - Transparent failover fallback to standard public feeds when cluster endpoints are temporarily unavailable.

2. **`SearchViewModel` (`lib/viewmodels/search/search_viewmodel.dart`):**
   - Manages tab state (`selectedTabIndex`: 0 = Properties, 1 = Jobs, 2 = Workers).
   - Manages sub-filter state:
     - **Properties:** `selectedPropertyType` (`null` for All, `'ROOM'`, `'APARTMENT'`, `'HOUSE'`).
     - **Jobs:** `selectedJobType` (`FULL_TIME`, `PART_TIME`, `CONTRACT`), `selectedWorkMode` (`REMOTE`, `ONSITE`, `HYBRID`).
     - **Workers:** `selectedWorkerService` (`ELECTRICIAN`, `PLUMBER`, etc.), `selectedWorkerAvailableToday`.
   - Dispatches search immediately upon switching tabs or tapping filter pills.
   - Built-in 300ms debounce timer on autocomplete keystrokes.

3. **`SearchView` (`lib/views/search/search_view.dart`):**
   - Category Selector Pills (`Properties`, `Jobs`, `Workers`).
   - Dynamic Sub-Filter Pills (e.g. `All Properties`, `Rooms`, `Apartments`, `Houses`).
   - Autocomplete Suggestions Dropdown.
   - Paginated result cards with badge indicators, photo carousels, and deep-linking to detail screens.

---

## 5. Verification Test Suite

A comprehensive test suite is maintained at `test/search_endpoints_test.dart`:
```bash
flutter test test/search_endpoints_test.dart
```
**Test Results:**
*   `GET /search/properties` -> **PASS (HTTP 200, parses PropertyModel)**
*   `GET /search/properties?type=ROOM` -> **PASS (HTTP 200, filters ROOM)**
*   `GET /search/properties?type=APARTMENT` -> **PASS (HTTP 200, filters APARTMENT)**
*   `GET /search/jobs` -> **PASS (HTTP 200, parses JobModel)**
*   `GET /search/worker-profiles` -> **PASS (HTTP 200, parses WorkerProfileModel)**
*   `GET /search/suggest` -> **PASS (HTTP 200, returns autocomplete suggestions)**
