# iOS prototype status

The active phone app uses SwiftUI and MapKit in mobile/ios/.
Android support is not included in this prototype.

## Verified on Hanrong's Mac

- Xcode build succeeded and the app ran in the iPhone 17 simulator.
- Xcode tests passed using Command-U.
- Sample first-choice and backup cards displayed and could be selected.
- The map could be moved and zoomed.
- The app fetched GET /locations from the local FastAPI backend.
- Stopping the backend produced a connection-error message.
- Restarting the backend and reloading restored the location catalog.

## Current limitations

- The backend location catalog still contains fictional sample locations.
- Verified parking coordinates are unavailable, so parking markers and
  marker/card interaction have not been demonstrated.
- Availability and walking estimates remain unknown.
- The backend recommendation endpoint is not implemented.
- Recommendation cards use clearly labeled bundled examples.
- Production location IDs, permit fields, and framework confirmation
  still require team coordination.
- A teammate setup walkthrough and DS3 code review remain pending.

Prediction, permit eligibility, and ranking belong in the shared backend.
