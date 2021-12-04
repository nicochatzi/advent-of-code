from typing import List, Callable
from collections import Counter


def transform_matrix(data: List[str]) -> List[str]:
    res = [''] * len(data[0])
    for line in data:
        for i, c in enumerate(line):
            res[i] += c
    return res


def gamma(data: List[str]) -> int:
    d = transform_matrix(data)
    res = ''.join([max(x, key=x.count) for x in d])
    return int(res, 2)


def epsilon(data: List[str]) -> int:
    d = transform_matrix(data)
    res = ''.join([min(x, key=x.count) for x in d])
    return int(res, 2)


def power(data: List[str]) -> int:
    return gamma(data) * epsilon(data)


def filter_with_criteria(data: List[str], predicate: Callable, idx: int) -> List[str]:
    if len(data) <= 1 or idx == len(data[0]):
        return data
    bit = predicate(transform_matrix(data)[idx])
    data = list(filter(lambda x: x[idx] == bit, data))
    return filter_with_criteria(data, predicate, idx+1)


def make_predicate(check: Callable) -> Callable:
    def predicate(data: List[str]) -> Callable:
        if len(set(data)) <= 1:
            return data[0]
        return check(Counter(data).most_common())
    return predicate


def oxygen(data: List[str]) -> int:
    predicate = make_predicate(
        lambda r: '1' if r[0][1] == r[1][1] else r[0][0])
    return int(filter_with_criteria(data, predicate, 0)[0], 2)


def co2(data: List[str]) -> int:
    predicate = make_predicate(
        lambda r: '0' if r[0][1] == r[1][1] else r[1][0])
    return int(filter_with_criteria(data, predicate, 0)[0], 2)


def life_support(data: List[str]) -> int:
    return oxygen(data) * co2(data)


if __name__ == '__main__':
    with open('res/star-4.txt', 'r') as f:
        data = f.read().split('\n')
        print(f'star 4 : {power(data)}')
        print(f'star 5 : {life_support(data)}')
