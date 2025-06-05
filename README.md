# Effective Mobile App

A simple task management application built using the MVVM architecture, CoreData for local data storage, a network layer for initial data loading, and unit tests.

## Features

- View a list of tasks
- Add, edit, and delete tasks
- Mark tasks as completed
- Search tasks by title and description
- Cache data loaded from the API
- Use CoreData for local storage and data persistence
- Unit tests for interactor logic

## Installation

1. Clone the repository:
   ```bash
   git clone [Your Repository URL]
   ```
2. Open the project in Xcode.
3. Build and run the project on a simulator or a physical device.

## Usage

The application presents a list of tasks. You can add new tasks by tapping the "+" button, edit existing tasks by selecting them from the list, delete tasks with a swipe, and mark them as completed/incomplete by tapping the completion indicator. Task search is also available via the search bar at the top of the screen.

## Testing

The project includes unit tests for `ToDoInteractor` and `AddTaskInteractor`, covering basic CRUD operations, search, and CoreData error handling.

To run tests:

1. Open the `effective-mobile` scheme in Xcode.
2. Select "Test" from the Product menu.
3. Alternatively, run tests from the Test Navigator in Xcode.

## Technologies

- UIKit
- CoreData
- URLSession (for network requests)
- XCTest (for unit tests)
- MVVM
