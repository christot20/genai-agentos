import csv
import random
from faker import Faker
from generate_location_data import get_random_zipcode, get_random_metro_area

fake = Faker()

COMPANIES = {
    "TechCorp Solutions": (80000, 180000),
    "HealthFirst Systems": (70000, 160000),
    "Global Finance Inc": (90000, 200000),
    "Green Energy Ltd": (75000, 170000),
    "Digital Innovations": (85000, 190000)
}

BENEFITS = [
    "20% off Peloton equipment and memberships",
    "Premium health insurance through BlueCross",
    "Dental and vision coverage through MetLife",
    "Pet insurance through TrustedPals",
    "24/7 virtual mental health counseling",
    "$2500 annual wellness stipend",
    "Gym membership reimbursement up to $100/month",
    "$500 monthly commuter benefits",
    "15% discount on local fitness classes",
    "Annual health screening services"
]

def generate_employee_data(num_employees=50):
    employees = []
    
    for i in range(num_employees):
        metro_area = get_random_metro_area()
        company = random.choice(list(COMPANIES.keys()))
        salary_range = COMPANIES[company]
        
        num_benefits = random.randint(3, 5)
        employee_benefits = ", ".join(random.sample(BENEFITS, num_benefits))
        
        employee = {
            'employee_id': f"EMP{str(i+1).zfill(4)}",
            'first_name': fake.first_name(),
            'last_name': fake.last_name(),
            'date_of_birth': fake.date_of_birth(minimum_age=22, maximum_age=65).strftime('%Y-%m-%d'),
            'gender': random.choice(['M', 'F', 'NB']),
            'job_title': fake.job(),
            'company': company,
            'salary': random.randint(salary_range[0], salary_range[1]),
            'metro_area': metro_area,
            'work_zip_code': get_random_zipcode(metro_area),
            'home_zip_code': get_random_zipcode(metro_area),
            'work_benefits': employee_benefits
        }
        employees.append(employee)
    
    return employees

def save_to_csv(employees, filename='data/employees.csv'):
    with open(filename, 'w', newline='', encoding='utf-8') as file:
        if employees:
            writer = csv.DictWriter(file, fieldnames=employees[0].keys())
            writer.writeheader()
            writer.writerows(employees)

if __name__ == "__main__":
    employees_data = generate_employee_data(50)
    save_to_csv(employees_data)