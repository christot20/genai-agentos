import logging 
from logging.handlers import RotatingFileHandler
import os
import inspect
logger = logging.getLogger(__name__)
logger.setLevel(logging.DEBUG)

current_working_dir = os.getcwd()
new_dir = os.path.join(f"{current_working_dir}/backend/src/Logger", r"logs")
os.makedirs(new_dir, exist_ok=True)

caller_frame = inspect.stack()[6]
calling_filename = os.path.splitext(os.path.basename(caller_frame.filename))[0]

handler = RotatingFileHandler(filename=f'{new_dir}/{calling_filename}.log',
                              maxBytes = 1_000_000,
                              backupCount = 1)
formatter = logging.Formatter("%(asctime)s - %(name)s - %(levelname)s - %(message)s")
handler.setFormatter(formatter)
logger.addHandler(handler)


def debug(message):
    logger.debug(message)

def info(message):
    logger.info(message)

def warning(message):
    logger.warning(message)

def error(message):
    logger.error(message)

def critical(message):
    logger.critical(message)


