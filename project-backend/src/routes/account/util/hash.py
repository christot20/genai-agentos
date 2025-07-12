import bcrypt



salt = bcrypt.gensalt()
def hash_string(string: str) -> str:
    return bcrypt.hashpw(string.encode("utf-8"), salt)