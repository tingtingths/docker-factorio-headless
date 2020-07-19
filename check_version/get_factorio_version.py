import json
import sys
from http.client import HTTPResponse
from urllib.parse import urlencode
from urllib.request import urlopen, Request

BASE_URL = 'https://rssthis.itdog.me/xeva'
SRC = 'https://wiki.factorio.com/Main_Page/Latest_versions'
STABLE_XPATH = '//*[@id="mw-content-text"]/div/ul[1]/li[1]/a'
EXPERIMENTAL_XPATH = '//*[@id="mw-content-text"]/div/ul[1]/li[2]/a'


def get_version(experimental=False):
    xpath = STABLE_XPATH if not experimental else EXPERIMENTAL_XPATH

    req = Request(
        '{}?{}'.format(BASE_URL, urlencode({"src": SRC, "xpath": xpath})),
        data=None,
        headers={
            'User-Agent': 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) '
                          'Chrome/51.0.2704.103 Safari/537.36'
        }
    )

    with urlopen(req) as resp:
        result = json.loads(resp.read().decode('utf-8'))['result']
        version = result[list(result.keys())[0]][0]
    return version


if __name__ == '__main__':
    exp = len(sys.argv) > 1 and sys.argv[1] == '--experimental'

    try:
        print(get_version(exp))
        exit(0)
    except Exception as e:
        print('Unexpected result. ' + str(e), file=sys.stderr)
        exit(1)
