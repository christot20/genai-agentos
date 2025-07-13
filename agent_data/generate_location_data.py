import random

# Common geographic regions with their zip code ranges
METRO_AREAS = {
    "New York Metro": {
        "ranges": [("10001", "11697"), ("07001", "07097")],  # Manhattan and North NJ
        "state": "NY/NJ"
    },
    "Los Angeles Metro": {
        "ranges": [("90001", "91618")],
        "state": "CA"
    },
    "Chicago Metro": {
        "ranges": [("60601", "60827")],
        "state": "IL"
    },
    "Houston Metro": {
        "ranges": [("77001", "77598")],
        "state": "TX"
    },
    "Phoenix Metro": {
        "ranges": [("85001", "85055")],
        "state": "AZ"
    }
}

def get_random_zipcode(metro_area):
    """Generate a random zipcode within the specified metro area"""
    ranges = METRO_AREAS[metro_area]["ranges"]
    selected_range = random.choice(ranges)
    return str(random.randint(int(selected_range[0]), int(selected_range[1]))).zfill(5)

def get_random_metro_area():
    """Select a random metro area"""
    return random.choice(list(METRO_AREAS.keys()))