# Clean Green Earth iOS App

The purpose of this app is to help users create events that bring together communities to help save the earth's environment.

## How to Build

The app is built using Swift 3 and Xcode 8. It uses Cocoapods for fetching its dependencies. Please run the following commands to build the app:

```
> pod repo update
> pod install
> open CleanGreenEarth.xcworkspace
```

## Features

### Authentication

The user can signup / signin using either email+password or facebook. Once the user has successfully signed in.

### Events

Once the user has successfully signs in, the apps takes the user to the main tabbed interface. There are three sections in the app:

- **Events Section**: This shows the list of events that the user has either created or is going to attend. 
  - To view more details of the event, the user can tap on that event in the list.
  - **Event Details**: This page shows details of the event that was selected. If the event that is being shown is not of the users, the user can choose to attend the event by switching the RSVP switch on.
  - The user can create new events by tapping on the plus icon in this section. This opens up a page to create new events.
  - **Create Event Page**: The user needs to fill the title, location, date+time and duration of the event to create a new event. The user can optionally give description to the event. An image can also be added to the event.
- **Events Search**: This is a map that allows the user to select a location and search events nearby that location. To select a location, tap on search button and select your location.
  - Selecting callout of an event, takes the user to the respective event details page.
- **Profile**: This is a profile screen that shows your Name and Email. The user can log out of the app from this screen.

