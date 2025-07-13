import csv
import random
from faker import Faker
from generate_location_data import get_random_zipcode, get_random_metro_area, METRO_AREAS

fake = Faker()

SPECIALIZATIONS = {
    "Primary Care Physician": [
        "Annual check-ups", "Preventive care", "Chronic disease management",
        "Vaccinations", "Health screenings"
    ],
    "Cardiologist": [
        "Heart disease treatment", "Cardiac imaging", "Stress tests",
        "Blood pressure management", "Cholesterol management"
    ],
    "Dermatologist": [
        "Skin cancer screening", "Acne treatment", "Eczema care",
        "Cosmetic procedures", "Psoriasis treatment"
    ],
    "Psychiatrist": [
        "Mental health evaluation", "Medication management", "Depression treatment",
        "Anxiety therapy", "ADHD management"
    ],
    "Orthopedist": [
        "Joint replacement", "Sports injuries", "Fracture care",
        "Arthritis treatment", "Physical therapy"
    ]
}

def generate_practitioner_data(num_practitioners=20):
    practitioners = []
    metro_assignments = {metro: max(2, num_practitioners // len(METRO_AREAS)) 
                        for metro in METRO_AREAS.keys()}
    
    for i in range(num_practitioners):
        available_metros = [m for m, count in metro_assignments.items() if count > 0]
        if not available_metros:
            break
            
        metro_area = random.choice(available_metros)
        metro_assignments[metro_area] -= 1
        
        specialization = random.choice(list(SPECIALIZATIONS.keys()))
        services = ", ".join(random.sample(SPECIALIZATIONS[specialization], 
                                         random.randint(2, 4)))
        
        practitioner = {
            'doctor_id': f"DOC{str(i+1).zfill(4)}",
            'first_name': fake.first_name(),
            'last_name': fake.last_name(),
            'specialization': specialization,
            'metro_area': metro_area,
            'office_address': fake.street_address(),
            'office_zip_code': get_random_zipcode(metro_area),
            'services': services
        }
        practitioners.append(practitioner)
    
    return practitioners

def save_to_csv(practitioners, filename='data/practitioners.csv'):
    with open(filename, 'w', newline='', encoding='utf-8') as file:
        if practitioners:
            writer = csv.DictWriter(file, fieldnames=practitioners[0].keys())
            writer.writeheader()
            writer.writerows(practitioners)

if __name__ == "__main__":
    practitioners_data = generate_practitioner_data(20)
    save_to_csv(practitioners_data)