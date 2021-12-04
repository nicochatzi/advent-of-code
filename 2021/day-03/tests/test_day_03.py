from day_03 import __version__
from day_03.lib import *


def test_version():
    assert __version__ == '0.1.0'


def test_translate_matrix():
    original = ["011", "100"]
    assert transform_matrix(original) == ["01", "10", "10"]


aoc_data = """00100
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


def test_aoc_input_star_4():
    assert gamma(aoc_data) == 22
    assert epsilon(aoc_data) == 9
    assert power(aoc_data) == 198


def test_aoc_input_star_5():
    assert oxygen(aoc_data) == 23
    assert co2(aoc_data) == 10
    assert life_support(aoc_data) == 230
