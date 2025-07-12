import bcrypt



def hash_string(m: str, salt: bytes | None = None):
    m_salt = bcrypt.gensalt() if salt is None else salt
    hashed_string = bcrypt.hashpw(password = m.encode("utf-8"),
                                  salt = m_salt).decode("utf-8")
    return m_salt, hashed_string