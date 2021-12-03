from typing import List


def translate_matrix(data: List[str]) -> List[str]:
    res = [''] * len(data[0])
    for line in data:
        for i in range(len(line)):
            res[i] += line[i]
    return res


def gamma(data: List[str]) -> float:
    d = translate_matrix(data)
    res = ''.join([max(x, key=x.count) for x in d])
    return int(res, 2)


def epsilon(data: List[str]) -> float:
    d = translate_matrix(data)
    res = ''.join([min(x, key=x.count) for x in d])
    return int(res, 2)


def power(data: List[str]) -> float:
    return gamma(data) * epsilon(data)


if __name__ == '__main__':
    with open('res/star-4.txt', 'r') as f:
        data = f.read().split('\n')
        print(f'star 4 : {power(data)}')
