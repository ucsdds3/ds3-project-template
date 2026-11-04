# iOS prototype status

The phone prototype uses SwiftUI and MapKit in mobile/ios/.
Android support is not included.

## Verified on Hanrong's Mac

- Xcode build and native tests passed.
- App ran in the iPhone 17 simulator.
- Sample cards displayed and could be selected.
- Stopping the backend displayed a connection error; restarting restored access.
- GET /locations loaded the backend's verified catalog and parking markers.
- POST /recommendations returned first-choice and distinct backup cards.
- Historical availability estimates displayed from the shared backend.
- Selecting the backup card updated its selection state and moved the map
  to its orange marker.
- All four Python mobile fixture tests passed after the backend integration.

## Limitations and remaining review work

- Destination input currently sends a name without coordinates, so walking
  estimates remain unavailable and ranking cannot use destination distance.
- Availability estimates come from historical surveys, not live occupancy.
- Prediction, permit eligibility, and ranking belong in the shared backend.
- Bundled sample mode remains separate and visibly labeled.
- Local recommendations require the processed analysis dataset; follow
  docs/pipeline.md to prepare it and restart the backend afterward.
- Physical-device operation and Android support have not been demonstrated.
- Framework confirmation with Yra and a teammate setup walkthrough remain pending.
- Update the README and outdated connection messages before requesting review.
- Complete the review report and final checks before opening the PR.
