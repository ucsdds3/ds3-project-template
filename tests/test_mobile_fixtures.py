"""Check bundled iOS samples against the shared Python API contract."""

import json
from pathlib import Path

import pytest

from src.api.locations import get_locations
from src.api.schemas import LocationsResponse, RecommendationResponse


ROOT = Path(__file__).resolve().parents[1]
RESOURCES = ROOT / "mobile/ios/ParkSmart/Resources"


@pytest.mark.parametrize("name", [
    "recommendation_example", "recommendation_no_suitable",
    "recommendation_not_implemented",
])
def test_mobile_recommendation_fixtures_match_shared_contract(name):
    """Copies must remain valid, explicitly illustrative, and unmodified."""
    copied = json.loads((RESOURCES / f"{name}.json").read_text())
    shared = json.loads((ROOT / f"docs/examples/backend/{name}.json").read_text())
    assert copied == shared
    response = RecommendationResponse.model_validate(copied)
    assert response.is_example
    for choice in (response.first_choice, response.backup_choice):
        if choice:
            assert choice.location.coordinates is None
            assert choice.estimated_available_fraction is None
            assert choice.estimated_walking_minutes is None


def test_mobile_catalog_matches_shared_sample_ids():
    """App fixtures cannot silently introduce a second ID or coordinate registry."""
    value = json.loads((RESOURCES / "locations_sample.json").read_text())
    catalog = LocationsResponse.model_validate(value)
    assert catalog == get_locations()
    assert catalog.data_status == "sample"
    assert all(location.coordinates is None for location in catalog.locations)
