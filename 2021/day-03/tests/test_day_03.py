from day_03 import __version__
from day_03.lib import *


def test_version():
    assert __version__ == '0.1.0'

def test_aoc_input():
    data = """00100
11110
10110
10111
10101
01111
00111
11100
10000
11001
00010
01010""".split('\n')
    assert gamma(data) == 22
    assert epsilon(data) == 9
    assert power(data) == 198