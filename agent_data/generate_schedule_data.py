import csv
import random
from datetime import datetime, timedelta
import pandas as pd

# Updated appointment durations and types
APPOINTMENT_CONFIG = {
    "Primary Care Physician": {
        "durations": [30, 45],  # minutes
        "types": ["Annual Physical", "Follow-up", "New Patient", "Sick Visit"]
    },
    "Cardiologist": {
        "durations": [45, 60, 90],
        "types": ["Initial Consultation", "Follow-up", "Stress Test", "ECG Review"]
    },
    "Dermatologist": {
        "durations": [30, 45],
        "types": ["Skin Screening", "Follow-up", "Procedure", "Consultation"]
    },
    "Psychiatrist": {
        "durations": [60, 90],
        "types": ["Initial Evaluation", "Medication Review", "Therapy Session"]
    },
    "Orthopedist": {
        "durations": [45, 60, 75],
        "types": ["Initial Consultation", "Follow-up", "Post-Surgery", "Injury Assessment"]
    }
}

def generate_schedule_data(practitioners_file='data/practitioners.csv', num_days=30):
    # Read practitioners data
    practitioners = pd.read_csv(practitioners_file)
    schedules = []
    
    # Start date is 3 weeks from now
    start_date = datetime.now() + timedelta(weeks=3)
    
    for _, doc in practitioners.iterrows():
        # Get configuration for this doctor's specialization
        config = APPOINTMENT_CONFIG[doc['specialization']]
        
        # Generate appointments for the next num_days
        for day in range(num_days):
            current_date = start_date + timedelta(days=day)
            
            # Skip weekends
            if current_date.weekday() >= 5:
                continue
            
            num = random.randint(1, 5) # adds random skip for weekdays
            if num == current_date.weekday():
                continue
                
            # Generate appointments for the day
            current_time = current_date.replace(hour=9, minute=0)  # Start at 9 AM
            end_time = current_date.replace(hour=17, minute=0)     # End at 5 PM
            
            while current_time < end_time:
                # 90% chance of having an appointment slot (increased from 80%)
                if random.random() < 0.9:
                    duration = random.choice(config['durations'])
                    appt_type = random.choice(config['types'])
                    
                    # Increased chance of booked appointments (70% booked, 20% available, 10% cancelled)
                    schedule = {
                        'doctor_id': doc['doctor_id'],
                        'first_name': doc['first_name'],
                        'last_name': doc['last_name'],
                        'specialization': doc['specialization'],
                        'appointment_date': current_time.strftime('%Y-%m-%d'),
                        'appointment_time': current_time.strftime('%H:%M'),
                        'appointment_duration': duration,
                        'appointment_type': appt_type,
                        'availability_status': random.choices(
                            ['Available', 'Booked', 'Cancelled'],
                            weights=[0.2, 0.7, 0.1]
                        )[0]
                    }
                    schedules.append(schedule)
                
                # Move time forward
                current_time += timedelta(minutes=duration)
    
    return schedules

def save_to_csv(schedules, filename='data/schedules.csv'):
    with open(filename, 'w', newline='', encoding='utf-8') as file:
        if schedules:
            writer = csv.DictWriter(file, fieldnames=schedules[0].keys())
            writer.writeheader()
            writer.writerows(schedules)

if __name__ == "__main__":
    schedules_data = generate_schedule_data()
    save_to_csv(schedules_data)
    print("Schedule data has been generated and saved to schedules.csv")