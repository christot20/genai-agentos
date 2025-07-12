import logging
import os



logging.basicConfig(level = logging.INFO,
                    format = '[%(asctime)s] [%(name)s] [%(levelname)s] ::: %(message)s',
                    handlers = [logging.StreamHandler()])
logger = logging.getLogger(__name__)



dbg_state = os.environ.get("DEBUG") == "true"
def dbg_log(m: str):
    if dbg_state:
        logger.info(m)

def log(m: str):
    logger.info(m)